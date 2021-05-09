# frozen_string_literal: true

# Represents form object for Event model
class EventForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :owner, Character
  attribute :dungeon, Dungeon
  attribute :fraction, Fraction
  attribute :name, String
  attribute :description, String, default: ''
  attribute :event_type, String
  attribute :eventable_id, Integer
  attribute :eventable_type, String
  attribute :start_time, DateTime
  attribute :hours_before_close, Integer, default: 0
  attribute :world_fraction, WorldFraction

  validates :name, :owner, :event_type, :eventable_id, :eventable_type, :start_time, :hours_before_close, :world_fraction, presence: true
  validates :event_type, inclusion: { in: %w[instance raid custom] }
  validates :eventable_type, inclusion: { in: Event::EVENTABLE_TYPES }
  validates :hours_before_close, inclusion: 0..24
  validates :name, length: { in: 2..50 }
  validate :valid_time?
  validate :eventable_exists?

  attr_reader :event

  def persist?
    # initial values
    self.event_type = define_event_type
    self.name = dungeon.name[I18n.locale.to_s] if name.blank? && dungeon.present?
    if owner.present?
      self.fraction = owner.race&.fraction
      self.world_fraction = owner.world_fraction
      self.eventable_id = owner.guild_id if eventable_type != 'Static'
    end
    # validation
    return false unless valid?

    @event = id ? Event.find_by(id: id) : Event.new
    return false if @event.nil?

    @event.attributes = attributes.except(:id)
    @event.save
    true
  end

  private

  def eventable_exists?
    return if eventable_type.nil?
    return if eventable_type.constantize.exists?(id: eventable_id)

    errors.add(:eventable, message: I18n.t('activemodel.errors.models.event_form.attributes.eventable.is_not_exist'))
  end

  def valid_time?
    return if start_time.nil?
    return if DateTime.now < start_time - hours_before_close.hours

    errors.add(:start_time, message: I18n.t('activemodel.errors.models.event_form.attributes.start_time.in_the_past'))
  end

  def define_event_type
    return (dungeon.raid? ? 'raid' : 'instance') if event_type.blank? && dungeon.present?

    'custom'
  end
end
