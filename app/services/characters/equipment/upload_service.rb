# frozen_string_literal: true

module Characters
  module Equipment
    class UploadService
      prepend BasicService

      def call(character:, input_value:)
        @character = character

        parse_input_value(input_value)
        return if failure?

        clear_character_equipment
        fetch_character_equipment
        reset_character_item_level
      end

      private

      def parse_input_value(input_value)
        @equipment_values = input_value.split(';').map { |value| value.split(':') }
        fail!('Invalid amount of equiped items') if @equipment_values.size != ::Equipment::SLOTS_AMOUNT
      end

      def clear_character_equipment
        @character.equipment.destroy_all
      end

      def fetch_character_equipment
        equipment = []
        @equipment_values.each.with_index do |value, index|
          next if value[0] == '0'

          equipment << @character.equipment.new(
            slot:         index,
            item_uid:     value[0],
            ench_uid:     value[1].to_s,
            game_item_id: GameItem.find_by(item_uid: value[0].to_i)&.id
          )
        end
        ::Equipment.import(equipment)
      end

      def reset_character_item_level
        @character.update(item_level_calculated: false)
      end
    end
  end
end
