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

  validates :name, :level, :race, :character_class, :user, :world, presence: true
  validates :level, inclusion: 1..60
  validate :race_class_restrictions
  validate :guild_from_world
  validate :race_from_fraction

  attr_reader :character

  def persist?
    self.world = guild.world if world.nil? && guild.present?
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
    return if class_is_valid_for_race?
    errors[:character_class] << 'is not valid for race'
  end

  def class_is_valid_for_race?
    return false if race.nil?
    return false if character_class.nil?
    case race.name['en']
      when 'Tauren' then %w[Druid Hunter Shaman Warrior].include?(character_class.name['en'])
      when 'Orc' then %w[Rogue Warlock Hunter Shaman Warrior].include?(character_class.name['en'])
      when 'Dwarf' then %w[Rogue Hunter Paladin Priest Warrior].include?(character_class.name['en'])
      when 'Undead' then %w[Mage Priest Rogue Warlock Warrior].include?(character_class.name['en'])
      when 'Human' then %w[Mage Paladin Priest Rogue Warlock Warrior].include?(character_class.name['en'])
      when 'Troll' then %w[Hunter Mage Priest Rogue Shaman Warrior].include?(character_class.name['en'])
      when 'Night Elf' then %w[Druid Hunter Priest Rogue Warrior].include?(character_class.name['en'])
      when 'Gnome' then %w[Mage Rogue Warlock Warrior].include?(character_class.name['en'])
      else false
    end
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
