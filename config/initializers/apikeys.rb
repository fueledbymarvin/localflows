ENV['google_key'] = "965729483714" 
ENV['google_secret'] = "ZZNZzAy7YP4_oRax39pMqGcX"
ENV['eventful_key'] = "QKfkq5gSS25fkGPQ"
ENV['groupme_key'] = "pUmGFA95Duyn8sbsOqneyxbTl0iQuRLbiNbNN4GCeb8oQAZ8"

Rails.application.config.middleware.use OmniAuth::Builder do
	provider :google_oauth2, ENV['google_key'], ENV['google_secret'],
	{
      name: "google",
      scope: "userinfo.email, userinfo.profile, calendar",
      prompt: "select_account consent",
      image_aspect_ratio: "square",
      image_size: 60,
      access_type: "offline",
      redirect_uri:'http://localflows.herokuapp.com/auth/google/callback'
    }
	#client_options: { :ssl => { :ca_file => '/usr/lib/ssl/certs/ca-certificates.crt' } }
end