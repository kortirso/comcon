# Represents how many characters event/guild/static need for raid/dungeon
class GroupRole < ApplicationRecord
  belongs_to :groupable, polymorphic: true
end
