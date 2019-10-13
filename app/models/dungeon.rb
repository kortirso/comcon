# Represents dungeons and raids
class Dungeon < ApplicationRecord
  has_many :dungeon_accesses, dependent: :destroy
  has_many :characters, through: :dungeon_accesses

  scope :with_key, -> { where key_access: true }
  scope :with_quest, -> { where quest_access: true }
end
