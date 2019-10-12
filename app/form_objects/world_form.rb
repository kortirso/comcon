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
    return false if exists?
    @world = id ? World.find_by(id: id) : World.new
    return false if @world.nil?
    @world.attributes = attributes.except(:id)
    @world.save
    true
  end

  private

  def exists?
    worlds = id.nil? ? World.all : World.where.not(id: id)
    worlds.find_by(name: name, zone: zone).present?
  end
end
