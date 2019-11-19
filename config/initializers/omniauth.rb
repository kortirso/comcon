Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.production?
    provider :discord, ENV['DISCORD_CLIENT_ID'], ENV['DISCORD_CLIENT_SECRET'], scope: 'email identify', callback_url: 'http://guild-hall.org/users/auth/discord/callback'
  else
    provider :discord, ENV['DISCORD_CLIENT_ID'], ENV['DISCORD_CLIENT_SECRET'], scope: 'email identify'
  end
end

token_verifier = OmniAuth.config.before_request_phase
OmniAuth.config.before_request_phase = proc do |env|
  begin
    token_verifier&.call(env)
  rescue ActionController::InvalidAuthenticityToken => e
    puts '----'
  end
end
