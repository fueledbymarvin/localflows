class User < ActiveRecord::Base

    def self.from_omniauth(auth)
        user = find_or_initialize_by(gid: auth.uid)

        user.name = auth.extra.raw_info.name
        user.email = auth.extra.raw_info.email
        if auth.extra.raw_info.picture
        	user.image = auth.extra.raw_info.picture
        end

        user.gaccess = auth.credentials.token
        user.grefresh = auth.credentials.refresh_token
        user.gid = auth.uid

        user.save

        user.gclient(user.gaccess)
        user.gcal
        user.eventful
        
        return user
    end

    def eventful
        @eventful ||= Eventful::API.new ENV['eventful_key']
    end

    def gclient(token)
    	@google ||= Google::APIClient.new
    	if token.nil?
    		@google.authorization.access_token = self.gaccess
    	else
    		@google.authorization.access_token = token
    	end
    	return @google
    end

    def gcal
    	@calendar ||= self.gclient(nil).discovered_api('calendar', 'v3')
    end

    def freebusy(start, offset, min, max, id)
    	user = User.find(id)
      	begin
            result = self.gclient(user.gaccess).execute(
                api_method: self.gcal.freebusy.query,
                body: JSON.dump({
                    timeMin: min,
                    timeMax: max,
                    items: [ { id: user.email} ]
                }),
                headers: {'Content-Type' => 'application/json'}
            )
	      	fb = { email: user.email, busy: Array.new(offset, false) }
            result.data.calendars[user.email].busy.each do |event|
                pos = getPos(start, offset, event.start, event.end)
                if pos
                    for i in pos[:startPos]..pos[:endPos]
                        fb[:busy][i] = true
                    end
                end
            end
            return fb
	    rescue
            refresh = HTTParty.post('https://accounts.google.com/o/oauth2/token', {
                body: {
                    client_id: ENV["google_key"],
                    client_secret: ENV["google_secret"],
                    refresh_token: user.grefresh,
                    grant_type: "refresh_token"
                }
            })
            user.gaccess = refresh.parsed_response["access_token"]
            user.save
            result = self.gclient(user.gaccess).execute(
                api_method: self.gcal.freebusy.query,
                body: JSON.dump({
                    timeMin: min,
                    timeMax: max,
                    items: [ { id: user.email} ]
                }),
                headers: {'Content-Type' => 'application/json'}
            )
            fb = { email: user.email, busy: Array.new(offset, false) }
            result.data.calendars[user.email].busy.each do |event|
                pos = getPos(start, offset, event.start, event.end)
                if pos
                    for i in pos[:startPos]..pos[:endPos]
                        fb[:busy][i] = true
                    end
                end
            end
            return fb
	    end
    end

    def group(min, max, ids, events)
    	start = min.to_time
    	offset = Integer((max.tomorrow.to_time - min.to_time) / 1800)
    	
        ids << self.id
    	all = {}
    	ids.each do |id|
    		all[id] = freebusy(start, offset, min.midnight.to_datetime.iso8601, max.midnight.to_datetime.iso8601, id)
    	end

        finalEvents = []
        newEvents = self.prune(events)
    	newEvents.each do |event|
    		s = event["start_time"]
    		e = event["stop_time"].nil? ? event["start_time"] + 3600 * 3 : event["stop_time"]
    		pos = getPos(start, offset, s, e)

    		if pos
		    	available = []
	    		ids.each do |id|
	    			a = false
	    			for i in pos[:startPos]..pos[:endPos]
	    				a = a || all[id][:busy][i]
	    			end
	    			unless a
	    				available << all[id][:email]
	    			end
	    		end
                me = false
                available.each do |email|
                    if email == self.email
                        me = true
                    end
                end
                if me && available.length > 1
    	    		event["available"] = available
                    finalEvents << event
                end
	    	end
    	end
    	return finalEvents
    end

    def getPos(start, offset, s, e)
    	if(s.to_time - start < 0 || e.to_time - (start + offset * 1800) > 0)
    		return nil
    	else
    		startPos = Integer((s.to_time - start) / 1800)
    		endPos = (e.to_time - start) / 1800
    		if(endPos - Integer(endPos) == 0)
	    		endPos = Integer(endPos) - 1
	    	else
	    		endPos = Integer(endPos)
	    	end
	    	return {startPos: startPos, endPos: endPos}
    	end
    end

    def prune(events)
    	fields = ["title", "start_time", "stop_time", "url", "description", "venue", "image"]
    	newEvents = []
    	events.each do |event|
    		if(event["stop_time"].nil? || !event["stop_time"].nil? && event["start_time"].strftime("%D") == event["stop_time"].strftime("%D"))
    			newEvent = {}
    			fields.each do |field|
    				if(field == "venue")
    					newEvent[field] = "#{event['venue_name']}\n#{event['venue_address']}\n#{event['city_name']}, #{event['region_abbr']}"
    					if event['postal_code']
    						newEvent[field] += " #{event['postal_code']}"
    					end
    				elsif field == "image" && !event["image"].nil?
                        newEvent[field] = event["image"]["medium"]["url"]
                    else
    					newEvent[field] = event[field]
    				end
    			end
    			newEvents << newEvent
    		end
    	end
    	return newEvents
    end
end
