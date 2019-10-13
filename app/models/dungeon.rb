# Represents dungeons and raids
class Dungeon < ApplicationRecord
  scope :with_key, -> { where key_access: true }
  scope :with_quest, -> { where quest_access: true }
end
