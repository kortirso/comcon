# frozen_string_literal: true

# Represents game fractions
class Fraction < ApplicationRecord
  has_many :races, dependent: :destroy
  has_many :guilds, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :statics, dependent: :destroy
  has_many :world_fractions, dependent: :destroy

  def self.cache_key(fractions, api)
    {
      api:         api,
      serializer:  'fractions',
      stat_record: fractions.maximum(:updated_at)
    }
  end
end
