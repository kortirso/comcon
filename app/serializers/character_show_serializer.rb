class CharacterShowSerializer < ActiveModel::Serializer
  attributes :id, :name, :level, :character_class_id, :race_id, :guild_id, :world_id, :main_role_id, :secondary_role_ids, :profession_ids, :main

  def main_role_id
    object.main_roles&.first&.id
  end

  def secondary_role_ids
    object.secondary_roles.pluck(:id)
  end

  def profession_ids
    object.professions.pluck(:id)
  end
end
