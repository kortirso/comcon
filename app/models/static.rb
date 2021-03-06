# frozen_string_literal: true

require 'babosa'

# Represents guild statics
class Static < ApplicationRecord
  include Groupable
  include Subscribeable
  extend FriendlyId

  belongs_to :staticable, polymorphic: true
  belongs_to :fraction
  belongs_to :world
  belongs_to :world_fraction

  has_many :static_members, dependent: :destroy
  has_many :characters, through: :static_members
  has_many :users, -> { distinct }, through: :characters, source: :user

  has_many :signed_subscribes, -> { where status: 'approved' }, as: :subscribeable, class_name: 'Subscribe'
  has_many :signed_characters, through: :signed_subscribes, source: :character

  has_many :static_invites, dependent: :destroy
  has_many :invited_characters, through: :static_invites, source: :static

  scope :privy, -> { where privy: true }
  scope :not_privy, -> { where privy: false }

  friendly_id :slug_candidates, use: :slugged

  after_save ThinkingSphinx::RealTime.callback_for(:static)

  trigger.after(:insert) do
    <<~SQL.squish
      PERFORM pg_advisory_xact_lock(NEW.world_id);

      INSERT INTO world_stats (world_id, statics_count)
      SELECT
        NEW.world_id as world_id,
        COUNT(statics.id) as statics_count
      FROM statics WHERE statics.world_id = NEW.world_id
      ON CONFLICT (world_id) DO UPDATE
      SET
        statics_count = EXCLUDED.statics_count;
    SQL
  end

  def self.cache_key_for_user(statics, user_id)
    {
      serializer:  'statics',
      stat_record: "user_#{user_id}/#{statics.maximum(:updated_at)}"
    }
  end

  def normalize_friendly_id(text)
    text.to_slug.transliterate(:russian).normalize.to_s
  end

  def for_guild?
    staticable_type == 'Guild'
  end

  def time_offset_value
    return staticable.time_offset.value if staticable_type == 'Guild'

    user_time_offset = staticable.user.time_offset.value
    return 0 if user_time_offset.nil?

    user_time_offset
  end

  def locale
    return staticable.locale if staticable_type == 'Guild'

    staticable.world.locale
  end

  private

  def slug_candidates
    [
      :name,
      %i[name staticable_id],
      %i[name staticable_id staticable_type],
      %i[name staticable_id staticable_type id]
    ]
  end
end
