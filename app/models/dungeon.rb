# frozen_string_literal: true

# Represents dungeons and raids
class Dungeon < ApplicationRecord
  has_many :events, dependent: :destroy

  def self.cache_key(dungeons, api)
    {
      api: api,
      serializer: 'dungeons',
      stat_record: dungeons.maximum(:updated_at)
    }
  end
end
