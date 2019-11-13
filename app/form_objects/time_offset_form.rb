# Represents form object for TimeOffset model
class TimeOffsetForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :user, User
  attribute :value, Integer, default: nil

  validates :user, presence: true
  validates :value, inclusion: -12..12, allow_nil: true

  attr_reader :time_offset

  def persist?
    return false unless valid?
    @time_offset = id ? TimeOffset.find_by(id: id) : TimeOffset.new
    return false if @time_offset.nil?
    @time_offset.attributes = attributes.except(:id)
    @time_offset.save
    true
  end
end
