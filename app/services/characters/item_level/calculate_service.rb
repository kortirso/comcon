# frozen_string_literal: true

module Characters
  module ItemLevel
    class CalculateService
      prepend BasicService

      def call
        characters.find_each(&method(:calc_item_level))
      end

      private

      def characters
        Character.includes(:equipment).where.not(equipment: { character_id: nil }).with_empty_item_level
      end

      def calc_item_level(character)
        battle_equip = character.equipment.battle_equip
        return if battle_equip.exists?(game_item_id: nil)

        character.update(item_level: battle_equip.item_level, item_level_calculated: true)
      end
    end
  end
end
