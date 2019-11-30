# Represents how many characters event/guild/static need for raid/dungeon
class GroupRole < ApplicationRecord
  belongs_to :groupable, polymorphic: true

  def self.default
    {
      tanks: {
        by_class: { warrior: 0, paladin: 0, druid: 0 }
      },
      healers: {
        by_class: { paladin: 0, druid: 0, priest: 0, shaman: 0 }
      },
      dd: {
        by_class: { warrior: 0, warlock: 0, druid: 0, hunter: 0, rogue: 0, priest: 0, shaman: 0, mage: 0, paladin: 0 }
      }
    }
  end

  def defined?
    value != GroupRole.default
  end
end
