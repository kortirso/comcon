Rails.application.config.middleware.use OmniAuth::Builder do
  provider :discord, ENV['DISCORD_CLIENT_ID'], ENV['DISCORD_CLIENT_SECRET'], scope: 'email identify'
end

token_verifier = OmniAuth.config.before_request_phase
OmniAuth.config.before_request_phase = proc do |env|
  begin
    token_verifier&.call(env)
  rescue ActionController::InvalidAuthenticityToken => e
    puts '----'
  end
end
