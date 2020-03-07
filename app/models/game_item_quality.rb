# frozen_string_literal: true

# Represents game item qualities
class GameItemQuality < ApplicationRecord
  has_many :game_items, dependent: :destroy
end
