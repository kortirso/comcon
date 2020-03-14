# frozen_string_literal: true

require 'babosa'

# Represents events
class Event < ApplicationRecord
  include Groupable
  include Subscribeable
  extend FriendlyId

  EVENTABLE_TYPES = %w[
    Guild
    Static
  ].freeze

  friendly_id :slug_candidates, use: :slugged

  belongs_to :owner, class_name: 'Character'
  belongs_to :dungeon, optional: true
  belongs_to :eventable, polymorphic: true
  belongs_to :fraction
  belongs_to :world_fraction

  has_many :characters, through: :subscribes
  has_many :users, -> { distinct }, through: :characters, source: :user

  has_many :signed_subscribes, -> { where status: %w[approved signed] }, as: :subscribeable, class_name: 'Subscribe'
  has_many :signed_characters, through: :signed_subscribes, source: :character
  has_many :signed_users, -> { distinct }, through: :signed_characters, source: :user

  scope :for_guild, ->(guild_id) { where eventable_type: 'Guild', eventable_id: guild_id }
  scope :for_static, ->(static_ids) { where eventable_type: 'Static', eventable_id: static_ids }

  def self.available_for_user(user_id)
    Event.joins(subscribes: :character).where(characters: { user_id: user_id })
  end

  def self.available_for_character(character_id)
    Event.joins(subscribes: :character).where(characters: { id: character_id })
  end

  def available_for_user?(user)
    users.where(id: user.id).exists?
  end

  def normalize_friendly_id(text)
    text.to_slug.transliterate(:russian).normalize.to_s
  end

  def is_open?
    DateTime.now < start_time - hours_before_close.hours
  end

  def guild_role_of_user(user_id)
    return nil if eventable_type == 'Static' && eventable.staticable_type == 'Character'
    guild = eventable_type == 'Static' ? eventable.staticable : eventable
    # leaders from guild of this user
    leaders = guild.characters_with_leader_role.select { |character| character.user_id == user_id }
    return nil if leaders.empty?
    return ['rl', nil] if leaders.any? { |character| character.guild_role.name == 'rl' }
    class_leading = leaders.select { |character| character.guild_role.name == 'cl' }
    return nil if class_leading.empty?
    ['cl', class_leading.map! { |character| character.character_class.name['en'] }]
  end

  private

  def slug_candidates
    [
      :name,
      %i[name id]
    ]
  end
end
