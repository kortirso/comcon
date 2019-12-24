# Represents dungeons and raids
class Dungeon < ApplicationRecord
  has_many :dungeon_accesses, dependent: :destroy
  has_many :characters, through: :dungeon_accesses
  has_many :events, dependent: :destroy

  scope :with_key, -> { where key_access: true }
  scope :with_quest, -> { where quest_access: true }

  def self.cache_key(dungeons, api)
    {
      api: api,
      serializer: 'dungeons',
      stat_record: dungeons.maximum(:updated_at)
    }
  end
end
