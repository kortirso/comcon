# Represents form object for Subscribe model
class SubscribeForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :event, Event
  attribute :character, Character
  attribute :status, String, default: 'signed'

  validates :event, :character, :status, presence: true
  validates :status, inclusion: { in: %w[unknown signed rejected approved] }

  attr_reader :subscribe, :event

  def persist?
    return false unless valid?
    @subscribe = id ? Subscribe.find_by(id: id) : Subscribe.new
    return false if @subscribe.nil?
    @subscribe.attributes = attributes.except(:id)
    @subscribe.save
    true
  end
end
