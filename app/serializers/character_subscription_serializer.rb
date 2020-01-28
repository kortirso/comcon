class CharacterSubscriptionSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :name, :level, :item_level, :character_class_name, :guild_name, :roles, :slug

  def character_class_name
    object.character_class.name
  end

  def guild_name
    object.guild&.full_name
  end

  def roles
    object.roles.order(main: :desc).pluck(:name)
  end
end
