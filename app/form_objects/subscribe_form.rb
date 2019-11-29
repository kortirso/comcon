# Represents form object for Subscribe model
class SubscribeForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :event, Event
  attribute :character, Character
  attribute :status, Integer, default: 2
  attribute :comment, String, default: nil
  attribute :for_role, Integer, default: nil

  validates :event, :character, :status, presence: true
  validates :status, inclusion: 0..4
  validates :for_role, inclusion: 0..2, allow_nil: true
  validates :comment, length: { maximum: 100 }, allow_nil: true

  attr_reader :subscribe

  def persist?
    self.status = status_to_integer
    self.for_role = for_role_to_integer
    return false unless valid?
    @subscribe = id ? Subscribe.find_by(id: id) : Subscribe.new
    return false if @subscribe.nil?
    @subscribe.attributes = attributes.except(:id)
    @subscribe.save
    true
  end

  private

  def status_to_integer
    return status if status.is_a?(Integer)
    case status
      when 'reserve' then 4
      when 'approved' then 3
      when 'signed' then 2
      when 'unknown' then 1
      when 'rejected' then 0
      else 1
    end
  end

  def for_role_to_integer
    return for_role if for_role.is_a?(Integer)
    case for_role
      when 'Dd' then 2
      when 'Healer' then 1
      when 'Tank' then 0
      else 2
    end
  end
end
