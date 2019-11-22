# Represents game worlds
class World < ApplicationRecord
  include Eventable

  has_many :characters, dependent: :destroy
  has_many :guilds, dependent: :destroy
  has_many :statics, dependent: :destroy
  has_many :world_fractions, dependent: :destroy

  def self.cache_key(worlds)
    {
      serializer: 'worlds',
      stat_record: worlds.maximum(:updated_at)
    }
  end

  def full_name
    "#{name} (#{zone})"
  end
end
