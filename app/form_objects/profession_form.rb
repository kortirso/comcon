# Represents form object for Profession model
class ProfessionForm
  include ActiveModel::Model
  include Virtus.model

  attribute :name, Hash
  attribute :main, Boolean, default: true
  attribute :recipeable, Boolean, default: false

  validates :name, presence: true
  validate :name_as_hash

  attr_reader :profession

  def persist?
    return false unless valid?
    return false if exists?
    @profession = Profession.new
    @profession.attributes = attributes
    @profession.save
    true
  end

  private

  def exists?
    Profession.find_by(name: name).present?
  end

  def name_as_hash
    return errors[:name] << 'Name is not hash' unless name.is_a?(Hash)
    errors[:name] << 'Name EN is empty' unless name['en'].present?
    errors[:name] << 'Name RU is empty' unless name['ru'].present?
  end
end
