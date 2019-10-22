# Represents game fractions
class Fraction < ApplicationRecord
  has_many :races, dependent: :destroy
  has_many :guilds, dependent: :destroy
  has_many :events, dependent: :destroy

  def self.cache_key(fractions)
    {
      serializer: 'fractions',
      stat_record: fractions.maximum(:updated_at)
    }
  end
end
