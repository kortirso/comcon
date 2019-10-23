# Represents game professions
class Profession < ApplicationRecord
  has_many :character_professions, dependent: :destroy
  has_many :characters, through: :character_professions
end
