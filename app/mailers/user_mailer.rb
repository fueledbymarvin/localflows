class UserMailer < ActionMailer::Base
    default from: "hxi33x@gmail.com"

    def event_confirmation(email)
        mail(to: email, subject: "You've been invited to an event!")
    end
end