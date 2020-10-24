# frozen_string_literal: true

class GuildIndexSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :slug, :fraction_id, :fraction_name, :world_id, :world_name, :locale, :time_offset_value, :characters_count

  def description
    object.description.truncate(200)
  end

  def fraction_name
    object.fraction.name
  end

  def world_name
    object.world.full_name
  end

  def time_offset_value
    object.time_offset&.value
  end
end
