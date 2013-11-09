class UserMailer < ActionMailer::Base
    default from: "hxi33x@gmail.com"

    def event_confirmation(current_user, event_title, event_descripton, email)
        @user = current_user
        @event_title = event_title
        @event_descripton = event_descripton
        mail(to: email, subject: "You've been invited to an event!")
    end
end