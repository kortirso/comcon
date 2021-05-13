# frozen_string_literal: true

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
  attribute :main, Boolean, default: false

  validates :name, :level, :race, :character_class, :user, :world, :world_fraction, presence: true
  validates :name, length: { in: 2..12 }
  validates :level, inclusion: 1..70
  validate :exists?
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
    return unless characters.exists?(name: name, world: world)

    errors.add(:character, message: I18n.t('activemodel.errors.models.character_form.attributes.character.already_exist'))
  end

  def race_from_fraction
    return if race.nil?
    return if guild.nil?
    return if guild.fraction.name['en'] == 'Horde' && %w[Tauren Orc Undead Troll].include?(race.name['en'])
    return if guild.fraction.name['en'] == 'Alliance' && %w[Dwarf Human Night\ Elf Gnome].include?(race.name['en'])

    errors.add(:race, message: I18n.t('activemodel.errors.models.character_form.attributes.race.is_not_valid'))
  end
end
