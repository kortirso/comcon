class CharacterSubscriptionSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :name, :level, :character_class_name, :guild_name, :main_role_name

  def character_class_name
    object.character_class.name
  end

  def guild_name
    object.guild&.full_name
  end

  def main_role_name
    return nil if object.main_roles.empty?
    object.main_roles[0].name
  end
end
