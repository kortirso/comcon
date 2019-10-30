class CharacterCrafterSerializer < ActiveModel::Serializer
  attributes :id, :name, :level, :character_class, :race, :guild

  def character_class
    object.character_class.name
  end

  def race
    object.race.name
  end

  def guild
    object.guild&.full_name
  end
end
