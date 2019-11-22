# Represents form object for Static model
class StaticForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :name, String
  attribute :staticable_id, Integer
  attribute :staticable_type, String
  attribute :description, String, default: ''
  attribute :privy, Boolean, default: true
  attribute :fraction, Fraction
  attribute :world, World
  attribute :world_fraction, WorldFraction

  validates :name, :staticable_id, :staticable_type, :fraction, :world, :world_fraction, presence: true
  validates :name, length: { in: 2..20 }
  validates :staticable_type, inclusion: { in: %w[Guild Character] }

  attr_reader :static

  def persist?
    return false unless staticable_exists?
    # initial values
    self.fraction = staticable_type == 'Guild' ? @staticable.fraction : @staticable.race.fraction
    self.world = @staticable.world
    self.world_fraction = WorldFraction.find_by(world: world, fraction: fraction)
    # continue validation
    return false unless valid?
    return false if exists?
    @static = id ? Static.find_by(id: id) : Static.new
    return false if @static.nil?
    @static.attributes = attributes.except(:id)
    @static.save
    true
  end

  private

  def staticable_exists?
    return false unless staticable_type.present?
    @staticable = staticable_type.constantize.find_by(id: staticable_id)
    @staticable.present?
  end

  def exists?
    statics = id.nil? ? Static.all : Static.where.not(id: id)
    statics.find_by(staticable_id: staticable_id, staticable_type: staticable_type, name: name).present?
  end
end
