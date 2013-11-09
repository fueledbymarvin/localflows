class User < ActiveRecord::Base

    def self.from_omniauth(auth) do
        
        # where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
        #   #stuff
        #   user.save!
        # end
    end
end
