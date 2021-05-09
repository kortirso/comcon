# frozen_string_literal: true

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
    return unless WorldFraction.exists?(world: world, fraction: fraction)

    errors.add(:world_fraction, message: 'is already exists')
  end
end
