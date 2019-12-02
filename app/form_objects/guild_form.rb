# Represents form object for Guild model
class GuildForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :name, String
  attribute :description, String, default: ''
  attribute :world, World
  attribute :fraction, Fraction
  attribute :world_fraction, WorldFraction

  validates :name, :world, :fraction, :world_fraction, presence: true
  validates :name, length: { in: 2..24 }
  validate :exists?

  attr_reader :guild

  def persist?
    self.name = name.capitalize if name.present?
    self.world_fraction = id ? world_fraction : WorldFraction.find_by(world: world, fraction: fraction)
    return false unless valid?
    @guild = id ? Guild.find_by(id: id) : Guild.new
    return false if @guild.nil?
    @guild.attributes = attributes.except(:id)
    @guild.save
    true
  end

  private

  def exists?
    guilds = id.nil? ? Guild.all : Guild.where.not(id: id)
    return unless guilds.where(name: name, world: world).exists?
    errors[:guild] << I18n.t('activemodel.errors.models.guild_form.attributes.guild.already_exist')
  end
end
