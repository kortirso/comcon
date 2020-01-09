# Service for uploading equipment for character
class CharacterEquipmentUpload
  def self.call(character_id:, value:)
    Equipment.where(character_id: character_id).destroy_all
    equipment = []
    value.split(';').each.with_index do |val, index|
      values = val.split(':')
      next if values[0] == '0'
      game_item_id = GameItem.find_by(item_uid: values[0].to_i)&.id
      equipment << Equipment.new(character_id: character_id, slot: index, item_uid: values[0], ench_uid: values[1].to_s, game_item_id: game_item_id)
    end
    Equipment.import(equipment)
    true
  rescue
    nil
  end
end
