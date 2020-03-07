# frozen_string_literal: true

# Represents data about previous characters lifes
class CharacterTransfer < ApplicationRecord
  belongs_to :character
  belongs_to :race
  belongs_to :world
  belongs_to :character_class
end
