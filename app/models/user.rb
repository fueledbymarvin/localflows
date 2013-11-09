class User < ActiveRecord::Base

    def self.from_omniauth(auth)
        user = find_or_initialize_by(gid: auth.extra.raw_info.uid)

        user.name = auth.extra.raw_info.name
        user.email = auth.extra.raw_info.email
        user.image = auth.extra.raw_info.picture

        user.gaccess = auth.credentials.token
        user.grefresh = auth.credentials.refresh_token

        user.save
        
        return user
    end

    def google
    	@google ||= Google::APIClient.new
    	@google.authorization.access_token = self.gaccess
    	@calendar ||= @google.discovered_api('calendar', 'v3')
    	result = @google.execute(
    		api_method: calendar.freebusy.query,
    		parameters: {
    			timeMin: Date.today.midnight.to_s,
    			timeMax: Date.tomorrow.midnight.to_s
    		}
    	)
    	puts result
    end

end
