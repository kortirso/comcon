# Represents form object for Subscribe model
class SubscribeForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :event, Event
  attribute :character, Character
  attribute :signed, Boolean, default: true
  attribute :approved, Boolean, default: false

  validates :event, :character, presence: true

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
