class UserMailer < ActionMailer::Base
    default from: "hxi33x@gmail.com"

    def event_confirmation(current_user, event_title, event_description, email)
        @user = current_user
        @event_title = event_title
        @event_description = event_description
        mail(to: email, subject: "You've been invited to an event!")
    end
end