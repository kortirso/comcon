# Represents form object for World model
class WorldForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :name, String
  attribute :zone, String

  validates :name, :zone, presence: true

  attr_reader :world

  def persist?
    return false unless valid?
    return false if id.nil? && exists?
    return false if id.present? && same_exists?
    @world = id ? World.find_by(id: id) : World.new
    return false if @world.nil?
    @world.attributes = attributes.except(:id)
    @world.save
    true
  end

  private

  def exists?
    World.find_by(name: name, zone: zone).present?
  end

  def same_exists?
    World.where.not(id: id).find_by(name: name, zone: zone).present?
  end
end
