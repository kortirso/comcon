# Represents character accesses to dungeons and raids
class DungeonAccess < ApplicationRecord
  belongs_to :character
  belongs_to :dungeon
end
