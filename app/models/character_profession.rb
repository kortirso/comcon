# Represents professions selected by characters
class CharacterProfession < ApplicationRecord
  belongs_to :character
  belongs_to :profession
end
