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

  validates :name, :level, :race, :character_class, :user, :world, :world_fraction, presence: true
  validates :name, length: { in: 2..20 }
  validates :level, inclusion: 1..60
  validate :race_class_restrictions
  validate :guild_from_world
  validate :race_from_fraction

  attr_reader :character

  def persist?
    self.world_fraction = WorldFraction.find_by(world: world, fraction: race&.fraction)
    return false unless valid?
    return false if exists?
    @character = id ? Character.find_by(id: id) : Character.new
    return false if @character.nil?
    @character.attributes = attributes.except(:id)
    @character.save
    true
  end

  private

  def exists?
    characters = id.nil? ? Character.all : Character.where.not(id: id)
    characters.find_by(name: name, world: world).present?
  end

  def race_class_restrictions
    return if race.nil?
    return if character_class.nil?
    return if Combination.find_by(character_class: character_class, combinateable: race).present?
    errors[:character_class] << 'is not valid for race'
  end

  def guild_from_world
    return if guild.nil?
    return if world == guild.world
    errors[:guild] << 'is not from selected world'
  end

  def race_from_fraction
    return if race.nil?
    return if guild.nil?
    return if guild.fraction.name['en'] == 'Horde' && %w[Tauren Orc Undead Troll].include?(race.name['en'])
    return if guild.fraction.name['en'] == 'Alliance' && %w[Dwarf Human Night\ Elf Gnome].include?(race.name['en'])
    errors[:race] << 'is not available for this fraction'
  end
end
