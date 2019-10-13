# Represents form object for Event model
class EventForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :owner, Character
  attribute :dungeon, Dungeon
  attribute :name, String
  attribute :event_type, String
  attribute :access, String, default: 'guild'
  attribute :start_time, DateTime

  validates :name, :owner, :event_type, :access, :start_time, presence: true
  validates :event_type, inclusion: { in: %w[instance raid] }
  validates :access, inclusion: { in: %w[guild world] }

  attr_reader :event

  def persist?
    self.event_type = (dungeon.raid? ? 'raid' : 'instance') if !event_type.present? && dungeon.present?
    self.name = dungeon.name[I18n.locale.to_s] if !name.present? && dungeon.present?
    return false unless valid?
    @event = id ? Event.find_by(id: id) : Event.new
    return false if @event.nil?
    @event.attributes = attributes.except(:id)
    @event.save
    true
  end
end
