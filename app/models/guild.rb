# Represents guild
class Guild < ApplicationRecord
  include Eventable
  extend FriendlyId

  friendly_id :slug_candidates, use: :slugged

  belongs_to :world
  belongs_to :fraction

  has_many :characters, dependent: :nullify

  def self.cache_key(guilds)
    {
      serializer: 'guilds',
      stat_record: guilds.maximum(:updated_at)
    }
  end

  def full_name(locale = 'en')
    "#{name}, #{fraction.name[locale]}, #{world.full_name}"
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
