# Represents users in the system
class User < ApplicationRecord
  include Personable
  include Deliveriable

  devise :database_authenticatable, :registerable, :validatable, :omniauthable, omniauth_providers: %i[discord]

  has_many :characters, dependent: :destroy
  has_many :guilds, -> { distinct }, through: :characters
  has_many :subscribes, through: :characters
  has_many :worlds, through: :characters
  has_many :static_members, through: :characters
  has_many :identities, dependent: :destroy
  has_one :time_offset, dependent: :destroy

  validates :role, presence: true, inclusion: { in: %w[user admin] }

  before_save :set_confirmation_token, on: :create
  after_commit :create_time_offset, on: :create
  after_commit :send_confirmation_token, on: :create

  def self.with_discord_identity
    includes(:identities).where('identities.provider = ?', 'discord').references(:identities)
  end

  # has characters of user any role in guild?
  def any_role?(guild_id, *allowed_roles)
    character_ids = Character.where(user_id: id, guild_id: guild_id).pluck(:id)
    GuildRole.where(guild_id: guild_id, character_id: character_ids, name: allowed_roles).exists?
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
    character_ids = Character.where(user_id: id).pluck(:id)
    static_ids = StaticMember.where(character_id: character_ids).pluck(:static_id)
    Static.where(id: static_ids)
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
      when 'World' then available_characters_for_world_event(eventable_id: event.eventable_id, fraction_id: event.fraction_id)
      when 'Guild' then available_characters_for_guild_event(eventable_id: event.eventable_id)
      when 'Static' then available_characters_for_static_event(eventable_id: event.eventable_id)
    end
  end

  def is_admin?
    role == 'admin'
  end

  def confirmed?
    !confirmed_at.nil?
  end

  private

  def set_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64.to_s if confirmation_token.nil? && confirmed_at.nil?
  end

  def create_time_offset
    return unless time_offset.nil?
    time_offset_form = TimeOffsetForm.new(user: self, value: nil)
    time_offset_form.persist?
  end

  def send_confirmation_token
    ConfirmUserEmailJob.perform_now(user_id: id) if confirmed_at.nil?
  end

  def available_characters_for_world_event(eventable_id:, fraction_id:)
    characters.joins(:race).where(world_id: eventable_id).where(races: { fraction_id: fraction_id })
  end

  def available_characters_for_guild_event(eventable_id:)
    characters.where(guild_id: eventable_id)
  end

  def available_characters_for_static_event(eventable_id:)
    characters.joins(:static_members).where(static_members: { static_id: eventable_id })
  end
end
