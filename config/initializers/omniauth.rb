Rails.application.config.middleware.use OmniAuth::Builder do  
  provider :twitter, configatron.consumer_key, configatron.consumer_secret
end