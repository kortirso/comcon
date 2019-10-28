class GuildCharacterSerializer < ActiveModel::Serializer
  attributes :id, :name, :level, :character_class, :race
  has_one :guild_role, serializer: GuildRoleSerializer

  def character_class
    object.character_class.name
  end

  def race
    object.race.name
  end
end
