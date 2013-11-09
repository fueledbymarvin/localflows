class User < ActiveRecord::Base

    def self.from_omniauth(auth)

        user = find_or_initialize_by(gid: auth.uid)

        user.name = auth.extra.raw_info.name
        user.email = auth.extra.raw_info.email
        user.image = auth.extra.raw_info.picture

        user.gaccess = auth.credentials.token
        user.grefresh = auth.credentials.refresh_token
        user.gid = auth.uid

        # raise .to_yaml

        user.save
        
        return user
    end
end