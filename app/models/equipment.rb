# frozen_string_literal: true

# Represents equipment of character
class Equipment < ApplicationRecord
  BEAUTY_SLOTS = [3, 18].freeze
  NUMBER_BATTLE_SLOTS = 17

  belongs_to :character
  belongs_to :game_item, optional: true

  scope :empty, -> { where game_item_id: nil }
  scope :battle_equip, -> { where.not slot: BEAUTY_SLOTS }

  def self.item_level
    (all.includes(:game_item).inject(0) { |acc, slot| acc + (slot.game_item&.level || 0) }) / NUMBER_BATTLE_SLOTS
  end
end
