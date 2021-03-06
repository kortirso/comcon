# frozen_string_literal: true

require 'babosa'

# Represent game characters
class Character < ApplicationRecord
  include Staticable
  extend FriendlyId

  friendly_id :slug_candidates, use: :slugged

  belongs_to :user, counter_cache: true
  belongs_to :race
  belongs_to :character_class
  belongs_to :world
  belongs_to :guild, optional: true, counter_cache: true
  belongs_to :world_fraction

  has_many :owned_events, class_name: 'Event', foreign_key: 'owner_id', dependent: :destroy

  has_many :subscribes, dependent: :destroy
  has_many :events, through: :subscribes, source: :subscribeable, source_type: 'Event'

  has_many :character_roles, dependent: :destroy
  has_many :roles, through: :character_roles
  has_many :main_character_roles, -> { where main: true }, class_name: 'CharacterRole'
  has_many :main_roles, through: :main_character_roles, source: :role
  has_many :secondary_character_roles, -> { where main: false }, class_name: 'CharacterRole'
  has_many :secondary_roles, through: :secondary_character_roles, source: :role

  has_many :character_professions, dependent: :destroy
  has_many :professions, through: :character_professions

  has_many :static_members, dependent: :destroy
  has_many :in_statics, through: :static_members, source: :static

  has_many :static_invites, dependent: :destroy
  has_many :invitations_to_statics, through: :static_invites, source: :static

  has_many :guild_invites, dependent: :destroy
  has_many :guild_invitations, through: :guild_invites, source: :guild

  has_many :bank_requests, dependent: :nullify

  has_many :character_transfers, dependent: :destroy

  has_many :equipment, dependent: :destroy

  has_one :guild_role, dependent: :destroy

  scope :with_empty_item_level, -> { where item_level_calculated: false }

  after_save ThinkingSphinx::RealTime.callback_for(:character)

  trigger.after(:insert) do
    <<~SQL.squish
      PERFORM pg_advisory_xact_lock(NEW.world_id);

      INSERT INTO world_stats (world_id, characters_count)
      SELECT
        NEW.world_id as world_id,
        COUNT(characters.id) as characters_count
      FROM characters WHERE characters.world_id = NEW.world_id
      ON CONFLICT (world_id) DO UPDATE
      SET
        characters_count = EXCLUDED.characters_count;
    SQL
  end

  def self.cache_key_for_user(characters)
    {
      serializer:  'characters',
      stat_record: "user_#{characters[0]&.user_id}/#{characters.maximum(:updated_at)}"
    }
  end

  def full_name
    "#{name} - #{world.full_name}"
  end

  def normalize_friendly_id(text)
    text.to_slug.transliterate(:russian).normalize.to_s
  end

  private

  def slug_candidates
    [
      :name,
      %i[name race_id],
      %i[name race_id world_id],
      %i[name race_id world_id id]
    ]
  end
end
