# Represent game characters
class Character < ApplicationRecord
  belongs_to :user
  belongs_to :race
  belongs_to :character_class
  belongs_to :world
end
