# frozen_string_literal: true

# Represents game worlds
class World < ApplicationRecord
  include Eventable

  has_many :characters, dependent: :destroy
  has_many :guilds, dependent: :destroy
  has_many :statics, dependent: :destroy
  has_many :world_fractions, dependent: :destroy

  has_one :world_stat, dependent: :destroy

  def self.cache_key(worlds, api)
    {
      api:         api,
      serializer:  'worlds',
      stat_record: worlds.maximum(:updated_at)
    }
  end

  def full_name
    "#{name} (#{zone})"
  end

  def locale
    return zone.downcase if %w[RU EN].include?(zone)

    'en'
  end
end
