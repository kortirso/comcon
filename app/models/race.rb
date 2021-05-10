# frozen_string_literal: true

# Represents races
class Race < ApplicationRecord
  include Combinateable

  belongs_to :fraction

  has_many :characters, dependent: :destroy
  has_many :character_classes, through: :combinations

  def self.dependencies
    Race.order(id: :desc).inject({}) { |races, race| races.merge(race.to_hash) }
  end

  def to_hash
    {
      id.to_s => {
        'name'              => name,
        'fraction_id'       => fraction_id
      }
    }
  end
end
