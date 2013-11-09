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
        
        return user
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

    def freebusy(min, max, id)
    	user = User.find(id)
    	result = self.gclient(user.gaccess).execute(
      		api_method: self.gcal.freebusy.query,
      		body: JSON.dump({
      			timeMin: min.midnight.to_datetime.utc.iso8601,
      			timeMax: max.tomorrow.midnight.to_datetime.utc.iso8601,
      			items: [ { id: user.email} ]
      		}),
      		headers: {'Content-Type' => 'application/json'}
      	)
      	begin
	      	if result.data.error["code"] == 401
	      		refresh = HTTParty.post('https://accounts.google.com/o/oauth2/token', {
	      			body: {
	      				client_id: ENV["google_key"],
	      				client_id: ENV["google_secret"],
	      				refresh_token: user.grefresh,
	      				grant_type: "refresh_token"
	      			}
	      		})
	      		user.gaccess = refresh.parsed_response["access_token"]
	      		user.save
	      	end
	      	result = self.gclient(user.gaccess).execute(
	      		api_method: self.gcal.freebusy.query,
	      		body: JSON.dump({
	      			timeMin: min.midnight.to_datetime.utc.iso8601,
	      			timeMax: max.midnight.to_datetime.utc.iso8601,
	      			items: [ { id: user.email} ]
	      		}),
	      		headers: {'Content-Type' => 'application/json'}
	      	)
	    rescue
	    end

	    busy = {}
	    temp = min
	    until temp == max.tomorrow do
	    	busy[temp.strftime("%D")] = Array.new(48, false)
	    	temp = temp.next
	    end
	    result.data.calendars[user.email].busy.each do |event|
	    	startHr = Integer(event.start.strftime("%H"))
	    	startMin = Integer(event.start.strftime("%M"))
	    	endHr = Integer(event.end.strftime("%H"))
	    	endMin = Integer(event.end.strftime("%M"))
	    	startPos = (startHr * 60 + startMin) / 30
	    	endPos = (endHr * 60 + endMin) / 30.0
	    	if(endPos - Integer(endPos) == 0)
	    		endPos = Integer(endPos) - 1
	    	else
	    		endPos = Integer(endPos)
	    	end
	    	for i in startPos..endPos
	    		busy[event.start.strftime("%D")][i] = true
	    	end
	    end
	    return busy
    end

end
