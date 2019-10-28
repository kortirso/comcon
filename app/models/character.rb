# Represent game characters
class Character < ApplicationRecord
  belongs_to :user
  belongs_to :race
  belongs_to :character_class
  belongs_to :world
  belongs_to :guild, optional: true

  has_many :dungeon_accesses, dependent: :destroy
  has_many :dungeons, through: :dungeon_accesses
  has_many :owned_events, class_name: 'Event', foreign_key: 'owner_id'
  has_many :subscribes, dependent: :destroy
  has_many :events, through: :subscribes
  has_many :character_roles, dependent: :destroy
  has_many :roles, through: :character_roles
  has_many :main_character_roles, -> { where main: true }, class_name: 'CharacterRole'
  has_many :main_roles, through: :main_character_roles, source: :role
  has_many :secondary_character_roles, -> { where main: false }, class_name: 'CharacterRole'
  has_many :secondary_roles, through: :secondary_character_roles, source: :role
  has_many :character_professions, dependent: :destroy
  has_many :professions, through: :character_professions
  has_one :guild_role, dependent: :destroy

  def self.has_guild_master?
    return false if first.nil?
    GuildRole.where(guild_id: first.guild_id, character_id: pluck(:id)).any? { |character_role| character_role.name == 'gm' }
  end
end
