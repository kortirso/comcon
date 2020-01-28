# Calc
class CalcItemLevelForCharacters
  attr_reader :characters

  def initialize
    @characters = Character.includes(:equipment).where.not(equipment: { character_id: nil }).with_empty_item_level
  end

  def call
    characters.each { |character| calc_item_level(character: character) }
  end

  private

  def calc_item_level(character:)
    battle_equip = character.equipment.battle_equip
    return if battle_equip.any? { |equip| equip.game_item_id.nil? }
    character.update(item_level: battle_equip.item_level, item_level_calculated: true)
  end
end
