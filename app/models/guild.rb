require 'babosa'

# Represents guild
class Guild < ApplicationRecord
  include Eventable
  include Staticable
  extend FriendlyId

  friendly_id :slug_candidates, use: :slugged

  belongs_to :world
  belongs_to :fraction

  has_many :characters, dependent: :nullify
  has_many :guild_roles, dependent: :destroy
  has_many :characters_with_role, through: :guild_roles, source: :character
  has_many :leader_guild_roles, -> { where(name: 'rl').or(where(name: 'cl')) }, class_name: 'GuildRole'
  has_many :characters_with_leader_role, through: :leader_guild_roles, source: :character
  has_many :deliveries, dependent: :destroy
  has_many :notifications, through: :deliveries

  def self.cache_key(guilds)
    {
      serializer: 'guilds',
      stat_record: guilds.maximum(:updated_at)
    }
  end

  def normalize_friendly_id(text)
    text.to_slug.transliterate(:russian).normalize.to_s
  end

  def full_name
    "#{name}, #{world.full_name}"
  end

  private

  def slug_candidates
    [
      :name,
      %i[name world_id],
      %i[name fraction_id world_id],
      %i[name fraction_id world_id id]
    ]
  end
end
