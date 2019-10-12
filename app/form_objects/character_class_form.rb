# Represents form object for CharacterClass model
class CharacterClassForm
  include ActiveModel::Model
  include Virtus.model

  attribute :name, Hash

  validates :name, presence: true
  validate :name_as_hash

  attr_reader :character_class

  def persist?
    return false unless valid?
    return false if exists?
    @character_class = CharacterClass.new
    @character_class.attributes = attributes
    @character_class.save
    true
  end

  private

  def exists?
    CharacterClass.find_by(name: name).present?
  end

  def name_as_hash
    return errors[:name] << 'Name is not hash' unless name.is_a?(Hash)
    errors[:name] << 'Name EN is empty' unless name['en'].present?
    errors[:name] << 'Name RU is empty' unless name['ru'].present?
  end
end
