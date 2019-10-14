# Represents form object for Subscribe model
class SubscribeForm
  include ActiveModel::Model
  include Virtus.model

  attribute :event, Event
  attribute :character, Character
  attribute :signed, Boolean, default: true
  attribute :approved, Boolean, default: false

  validates :event, :character, presence: true

  attr_reader :subscribe, :event

  def persist?
    return false unless valid?
    @subscribe = Subscribe.new
    @subscribe.attributes = attributes.except(:id)
    @subscribe.save
    true
  end
end
