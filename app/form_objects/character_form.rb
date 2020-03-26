# Represents form object for Character model
class CharacterForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :name, String
  attribute :level, Integer, default: 60
  attribute :race, Race
  attribute :character_class, CharacterClass
  attribute :user, User
  attribute :world, World
  attribute :guild, Guild
  attribute :world_fraction, WorldFraction
  attribute :main, Boolean

  validates :name, :level, :race, :character_class, :user, :world, :world_fraction, presence: true
  validates :name, length: { in: 2..12 }
  validates :level, inclusion: 1..60
  validate :exists?
  validate :race_class_restrictions
  validate :race_from_fraction

  attr_reader :character

  def persist?
    self.name = name.capitalize if name.present?
    self.world_fraction = id ? world_fraction : WorldFraction.find_by(world: world, fraction: race&.fraction)
    return false unless valid?
    @character = id ? Character.find_by(id: id) : Character.new
    return false if @character.nil?
    @character.attributes = attributes.except(:id)
    @character.save
    true
  end

  private

  def exists?
    characters = id.nil? ? Character.all : Character.where.not(id: id)
    return unless characters.where(name: name, world: world).exists?
    errors[:character] << I18n.t('activemodel.errors.models.character_form.attributes.character.already_exist')
  end

  def race_class_restrictions
    return if race.nil?
    return if character_class.nil?
    return if Combination.find_by(character_class: character_class, combinateable: race).present?
    errors[:character_class] << I18n.t('activemodel.errors.models.character_form.attributes.character_class.is_not_valid')
  end

  def race_from_fraction
    return if race.nil?
    return if guild.nil?
    return if guild.fraction.name['en'] == 'Horde' && %w[Tauren Orc Undead Troll].include?(race.name['en'])
    return if guild.fraction.name['en'] == 'Alliance' && %w[Dwarf Human Night\ Elf Gnome].include?(race.name['en'])
    errors[:race] << I18n.t('activemodel.errors.models.character_form.attributes.race.is_not_valid')
  end
end
