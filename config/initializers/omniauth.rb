# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.production?
    provider :discord, ENV['DISCORD_CLIENT_ID'], ENV['DISCORD_CLIENT_SECRET'], scope: 'email identify', callback_url: 'https://guild-hall.org/users/auth/discord/callback'
  else
    provider :discord, ENV['DISCORD_CLIENT_ID'], ENV['DISCORD_CLIENT_SECRET'], scope: 'email identify', callback_url: 'http://localhost:5000/users/auth/discord/callback'
  end
end

token_verifier = OmniAuth.config.before_request_phase
OmniAuth.config.before_request_phase = proc do |env|
  token_verifier&.call(env)
rescue ActionController::InvalidAuthenticityToken => _e
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
end
