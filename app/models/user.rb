# frozen_string_literal: true

# Represents users in the system
class User < ApplicationRecord
  include Personable
  include Deliveriable
  include Tokenable
  include Timeable

  devise :database_authenticatable, :registerable, :validatable, :omniauthable, omniauth_providers: %i[discord]

  has_many :characters, -> { includes :guild }, dependent: :destroy
  has_many :guilds, -> { distinct }, through: :characters
  has_many :subscribes, through: :characters
  has_many :worlds, through: :characters
  has_many :static_members, through: :characters
  has_many :world_fractions, through: :characters
  has_many :identities, dependent: :destroy

  validates :role, presence: true, inclusion: { in: %w[user admin] }

  before_create :set_confirmation_token
  after_commit :create_time_offset, on: :create
  after_commit :send_confirmation_token, on: :create

  def self.with_discord_identity
    includes(:identities).where('identities.provider = ?', 'discord').references(:identities)
  end

  # has characters of user any role in guild?
  def any_role?(guild_id, *allowed_roles)
    character_ids = Character.where(user_id: id, guild_id: guild_id).pluck(:id)
    GuildRole.exists?(guild_id: guild_id, character_id: character_ids, name: allowed_roles)
  end

  def any_static_role?(static)
    return true if static.staticable_type == 'Guild' && any_role?(static.staticable_id, 'gm', 'rl')
    return true if static.staticable_type == 'Character' && characters.pluck(:id).include?(static.staticable_id)

    false
  end

  def any_character_in_static?(static)
    return true if static_members.pluck(:static_id).include?(static.id)

    false
  end

  def statics
    static_ids = (static_members.pluck(:static_id) + guild_static_ids_as_guild_leader).uniq
    Static.where(id: static_ids)
  end

  def guild_static_ids_as_guild_leader(guild_static_ids=[])
    characters.where.not(guild_id: nil).includes(:guild).find_each do |character|
      next unless any_role?(character.guild_id, 'gm', 'rl', 'cl')

      guild_static_ids << character.guild.statics.pluck(:id)
    end
    guild_static_ids.flatten.uniq
  end

  def static_invites
    character_ids = Character.where(user_id: id).pluck(:id)
    StaticInvite.where(character_id: character_ids, status: 0)
  end

  def guild_invites
    character_ids = Character.where(user_id: id).pluck(:id)
    GuildInvite.where(character_id: character_ids, status: 0, from_guild: true)
  end

  def available_characters_for_event(event:)
    case event.eventable_type
    when 'World' then characters.where(world_fraction_id: event.world_fraction_id)
    when 'Guild' then characters.where(guild_id: event.eventable_id)
    when 'Static' then characters.joins(:static_members).where(static_members: { static_id: event.eventable_id })
    end
  end

  def is_admin?
    role == 'admin'
  end

  def confirmed?
    !confirmed_at.nil?
  end

  def has_characters_in_guild?(guild_id:)
    characters.exists?(guild_id: guild_id)
  end

  private

  def set_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64.to_s if confirmation_token.nil? && confirmed_at.nil?
  end

  def create_time_offset
    return unless time_offset.nil?

    TimeOffset.create(timeable: self, value: nil)
  end

  def send_confirmation_token
    ConfirmUserEmailJob.perform_later(user_id: id) if confirmed_at.nil?
  end
end
