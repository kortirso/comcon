# Represents form object for Guild model
class GuildForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :name, String
  attribute :world, World
  attribute :fraction, Fraction

  validates :name, :world, :fraction, presence: true

  attr_reader :guild

  def persist?
    return false unless valid?
    return false if exists?
    @guild = id ? Guild.find_by(id: id) : Guild.new
    return false if @guild.nil?
    @guild.attributes = attributes.except(:id)
    @guild.save
    true
  end

  private

  def exists?
    guilds = id.nil? ? Guild.all : Guild.where.not(id: id)
    guilds.find_by(name: name, world: world).present?
  end
end
