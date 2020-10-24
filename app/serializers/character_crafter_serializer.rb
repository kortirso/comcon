# frozen_string_literal: true

class CharacterCrafterSerializer < ActiveModel::Serializer
  attributes :id, :name, :level, :character_class_name, :guild_name, :world_name, :slug, :world_id, :fraction_id, :guild_id

  def character_class_name
    object.character_class.name
  end

  def world_name
    object.world.full_name
  end

  def guild_name
    object.guild&.full_name
  end

  def fraction_id
    object.race.fraction_id
  end
end
