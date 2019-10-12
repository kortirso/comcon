# Represents character classes
class CharacterClass < ApplicationRecord
  has_many :characters, dependent: :destroy
end
