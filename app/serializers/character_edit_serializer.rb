class CharacterEditSerializer < ActiveModel::Serializer
  attributes :id, :name, :level, :character_class, :race, :guild, :world, :main_role
  has_many :dungeons
  has_many :secondary_roles

  def character_class
    object.character_class.name
  end

  def race
    object.race.name
  end

  def guild
    object.guild&.full_name
  end

  def world
    return nil if object.guild_id.present?
    object.world.name
  end

  def main_role
    object.main_roles&.first&.name
  end
end
