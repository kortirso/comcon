# Represents form object for Event model
class EventForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :owner, Character
  attribute :dungeon, Dungeon
  attribute :fraction, Fraction
  attribute :name, String
  attribute :event_type, String
  attribute :eventable_id, Integer
  attribute :eventable_type, String
  attribute :start_time, DateTime
  attribute :hours_before_close, Integer, default: 0

  validates :name, :owner, :event_type, :eventable_id, :eventable_type, :start_time, :hours_before_close, presence: true
  validates :event_type, inclusion: { in: %w[instance raid] }
  validates :eventable_type, inclusion: { in: %w[World Guild] }
  validates :hours_before_close, inclusion: 0..24

  attr_reader :event

  def persist?
    # initial values
    self.event_type = (dungeon.raid? ? 'raid' : 'instance') if !event_type.present? && dungeon.present?
    self.name = dungeon.name[I18n.locale.to_s] if !name.present? && dungeon.present?
    self.eventable_id = (eventable_type == 'World' ? owner.world.id : owner.guild&.id) if owner.present?
    self.fraction = owner.race.fraction if owner.present?
    # validation
    return false unless valid?
    return false unless eventable_exists?
    return false unless valid_time?
    @event = id ? Event.find_by(id: id) : Event.new
    return false if @event.nil?
    @event.attributes = attributes.except(:id)
    @event.save
    true
  end

  private

  def eventable_exists?
    eventable_type.constantize.find_by(id: eventable_id).present?
  end

  def valid_time?
    DateTime.now < start_time - hours_before_close.hours
  end
end
