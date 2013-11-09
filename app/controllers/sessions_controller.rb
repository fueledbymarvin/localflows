class SessionsController < ApplicationController
    def create
        user = User.from_omniauth(env["omniauth.auth"])
        session[:user_id] = user.id
        source = session[:source] || :root
        session[:source] = nil
        redirect_to source, :notice => "Signed in!"
    end

    def destroy
        reset_session
        redirect_to :root, :notice => "Signed out!"
    end
end
