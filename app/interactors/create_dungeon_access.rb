# Create DungeonAccess
class CreateDungeonAccess
  include Interactor

  # required context
  # context.character_id
  # context.dungeon_params
  def call
    context.dungeon_params.each do |dungeon_id, value|
      if value == '1'
        DungeonAccess.create(character_id: context.character_id, dungeon_id: dungeon_id.to_i)
      elsif value == '0'
        dungeon_access = DungeonAccess.find_by(character_id: context.character_id, dungeon_id: dungeon_id.to_i)
        next if dungeon_access.nil?
        dungeon_access.destroy
      end
    end
  end
end
