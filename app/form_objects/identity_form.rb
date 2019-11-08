# Represents form object for Identity model
class IdentityForm
  include ActiveModel::Model
  include Virtus.model

  attribute :uid, String
  attribute :provider, String
  attribute :email, String
  attribute :user, User

  validates :uid, :provider, :user, presence: true
  validate :exists?

  attr_reader :identity

  def persist?
    return false unless valid?
    @identity = Identity.new
    @identity.attributes = attributes
    @identity.save
    true
  end

  private

  def exists?
    return unless Identity.where(uid: uid, provider: provider).exists?
    errors[:identity] << 'already exists'
  end
end
