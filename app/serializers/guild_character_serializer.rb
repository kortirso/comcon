class GuildCharacterSerializer < ActiveModel::Serializer
  attributes :id, :name, :level, :item_level, :character_class_name, :race_name, :main_role_name, :slug
  has_one :guild_role, serializer: GuildRoleSerializer

  def character_class_name
    object.character_class.name
  end

  def race_name
    object.race.name
  end

  def main_role_name
    return nil if object.main_roles.empty?
    object.main_roles[0].name
  end
end
