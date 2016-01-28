LinkedIn.configure do |config|
  config.token = ENV['LINKEDIN_OAUTH_CLIENT_ID']
  config.secret = ENV['LINKEDIN_OAUTH_CLIENT_SECRET']
end