class CharacterEditSerializer < ActiveModel::Serializer
  attributes :id, :name, :level, :character_class_id, :race_id, :guild_id, :world_id, :main_role_id, :secondary_role_ids, :dungeon_ids

  def main_role_id
    object.main_roles&.first&.id
  end

  def secondary_role_ids
    object.secondary_roles.pluck(:id)
  end

  def dungeon_ids
    object.dungeons.pluck(:id)
  end
end
