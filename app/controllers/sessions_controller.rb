class SessionsController < ApplicationController
    def create
        if env["omniauth.origin"] == "login"
            if User.where(gid: env["omniauth.auth"].uid).empty?
                flash[:error] = "You don't have an account yet."
                redirect_to :root
            else
                user = User.from_omniauth(env["omniauth.auth"], nil)
                session[:user_id] = user.id
                # source = session[:source] || :root
                session[:source] = nil

                redirect_to :root, :notice => "Signed in!"
            end
        else
            citystate = env["omniauth.origin"].split(",")
            user = User.from_omniauth(env["omniauth.auth"], citystate)
            session[:user_id] = user.id
            # source = session[:source] || :root
            session[:source] = nil

            redirect_to :root, :notice => "Successfully created account!"
        end
    end

    def destroy
        reset_session
        redirect_to :root, :notice => "Signed out!"
    end
end
