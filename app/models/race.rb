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
        'name' => name,
        'character_classes' => character_classes.includes(:combinateables).order(id: :desc).inject({}) do |classes, character_class|
          classes.merge(character_class.to_hash)
        end
      }
    }
  end
end
