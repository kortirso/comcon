# frozen_string_literal: true

# Represents form object for TimeOffset model
class TimeOffsetForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :timeable_id, Integer
  attribute :timeable_type, String
  attribute :value, Integer, default: nil

  validates :timeable_id, :timeable_type, presence: true
  validates :timeable_type, inclusion: { in: %w[User Guild] }
  validates :value, inclusion: -12..12, allow_nil: true
  validate :timeable_exists?

  attr_accessor :timeable
  attr_reader :time_offset

  def persist?
    return false unless valid?

    @time_offset = id ? TimeOffset.find_by(id: id) : TimeOffset.new
    return false if @time_offset.nil?

    @time_offset.attributes = attributes.except(:id)
    @time_offset.save
    true
  end

  private

  def timeable_exists?
    return if timeable_type.blank?
    return if timeable_type.constantize.exists?(id: timeable_id)

    errors.add(:timeable, message: 'is not exists')
  end
end
