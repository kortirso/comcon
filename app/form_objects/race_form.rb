# Represents form object for Race model
class RaceForm
  include ActiveModel::Model
  include Virtus.model

  attribute :name, Hash
  attribute :fraction, Fraction

  validates :name, :fraction, presence: true
  validate :name_as_hash

  attr_reader :race

  def persist?
    return false unless valid?
    return false if exists?
    @race = Race.new
    @race.attributes = attributes
    @race.save
    true
  end

  private

  def exists?
    Race.find_by(name: name).present?
  end

  def name_as_hash
    return errors[:name] << 'Name is not hash' unless name.is_a?(Hash)
    errors[:name] << 'Name EN is empty' unless name['en'].present?
    errors[:name] << 'Name RU is empty' unless name['ru'].present?
  end
end
