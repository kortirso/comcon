require 'jwt'

# Service for encode/decode JWT tokens
class JwtService
  JWT_TTL = 2190

  # encode user_id, returns token, expiration time and user information
  def json_response(args = {}, expiration = nil)
    token, expiration = encode({ user_id: args[:user].id }, expiration)
    {
      access_token: token,
      user: { id: args[:user].id, email: args[:user].email },
      expires_at: expiration
    }
  end

  # decode token
  def decode(args = {})
    JWT.decode(args[:access_token], jwt_secret)[0]
  rescue
    nil
  end

  private

  # encode user information
  def encode(payload, expiration = nil)
    expiration ||= JWT_TTL.hours.from_now.to_i

    payload = payload.dup
    payload['exp'] = expiration

    [JWT.encode(payload, jwt_secret), expiration]
  end

  # secret
  def jwt_secret
    Rails.application.secrets.secret_key_base
  end
end
