# Represents form object for Event model
class EventForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :owner, Character
  attribute :dungeon, Dungeon
  attribute :name, String
  attribute :event_type, String
  attribute :eventable_id, Integer
  attribute :eventable_type, String
  attribute :start_time, DateTime

  validates :name, :owner, :event_type, :eventable_id, :eventable_type, :start_time, presence: true
  validates :event_type, inclusion: { in: %w[instance raid] }
  validates :eventable_type, inclusion: { in: %w[World Guild] }

  attr_reader :event

  def persist?
    self.event_type = (dungeon.raid? ? 'raid' : 'instance') if !event_type.present? && dungeon.present?
    self.name = dungeon.name[I18n.locale.to_s] if !name.present? && dungeon.present?
    self.eventable_id = (eventable_type == 'World' ? owner.world.id : owner.guild&.id) if owner.present?
    return false unless valid?
    return false unless eventable_exists?
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
end
