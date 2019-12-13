require 'babosa'

# Represents guild
class Guild < ApplicationRecord
  include Eventable
  include Staticable
  include Deliveriable
  extend FriendlyId

  friendly_id :slug_candidates, use: :slugged

  belongs_to :world
  belongs_to :fraction
  belongs_to :world_fraction

  has_many :characters, dependent: :nullify
  has_many :users, -> { distinct }, through: :characters, source: :user

  has_many :guild_roles, dependent: :destroy
  has_many :characters_with_role, through: :guild_roles, source: :character

  has_many :head_guild_roles, -> { where(name: 'gm') }, class_name: 'GuildRole'
  has_many :characters_with_head_role, through: :head_guild_roles, source: :character
  has_many :head_users, -> { distinct }, through: :characters_with_head_role, source: :user

  has_many :leader_guild_roles, -> { where(name: 'rl').or(where(name: 'cl')) }, class_name: 'GuildRole'
  has_many :characters_with_leader_role, through: :leader_guild_roles, source: :character

  has_many :guild_invites, dependent: :destroy
  has_many :character_invitations, through: :guild_invites, source: :character

  has_many :banks, dependent: :destroy
  has_many :bank_requests, -> { distinct }, through: :banks

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
