# service for searching/creating identities with users
class Oauth
  def self.find_user(auth)
    identity = Identity.find_for_oauth(auth)
    return identity.user if identity.present?
    email = auth.info[:email]
    return false if email.nil?
    user = User.find_or_create_by(email: email) do |u|
      u.password = Devise.friendly_token[0, 20]
    end
    CreateIdentity.call(uid: auth.uid, provider: auth.provider, user: user, email: email)
    user
  end
end
