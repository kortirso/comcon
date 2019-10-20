# Represents races
class Race < ApplicationRecord
  include Combinateable

  belongs_to :fraction

  has_many :characters, dependent: :destroy
  has_many :character_classes, through: :combinations
end
