class User < ActiveRecord::Base

    def self.from_omniauth(auth)
        p auth
        # where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
        #   #stuff
        #   user.save!
        # end
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
