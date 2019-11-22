# Represents form object for WorldFraction model
class WorldFractionForm
  include ActiveModel::Model
  include Virtus.model

  attribute :world, World
  attribute :fraction, Fraction

  validates :world, :fraction, presence: true
  validate :exists?

  attr_reader :world_fraction

  def persist?
    return false unless valid?
    @world_fraction = WorldFraction.new
    @world_fraction.attributes = attributes
    @world_fraction.save
    true
  end

  private

  def exists?
    return unless WorldFraction.where(world: world, fraction: fraction).exists?
    errors[:world_fraction] << 'is already exists'
  end
end
