# frozen_string_literal: true

class CharacterSerializer < ActiveModel::Serializer
  attributes :id, :name, :level, :character_class_name, :race_name, :guild_name, :user_id

  def character_class_name
    object.character_class.name
  end

  def race_name
    object.race.name
  end

  def guild_name
    object.guild&.name
  end
end
