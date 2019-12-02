# service for searching/creating identities with users
class Oauth
  def self.auth_login(auth:)
    identity = Identity.find_for_oauth(auth)
    return identity.user if identity.present?
    email = auth.info[:email]
    return false if email.nil?
    user = User.find_or_create_by(email: email) do |u|
      u.password = Devise.friendly_token[0, 20]
      u.confirmed_at = DateTime.now
    end
    ConfirmUser.call(user: user)
    CreateIdentity.call(uid: auth.uid, provider: auth.provider, user: user, email: email)
    user
  end

  def self.auth_binding(auth:, user:)
    identity = Identity.find_for_oauth(auth)
    return if identity.present?
    CreateIdentity.call(uid: auth.uid, provider: auth.provider, user: user, email: auth.info[:email])
  end
end
