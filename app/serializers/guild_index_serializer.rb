class GuildIndexSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :slug, :fraction_id, :fraction_name, :world_id, :world_name

  def description
    object.description.truncate(200)
  end

  def fraction_name
    object.fraction.name
  end

  def world_name
    object.world.full_name
  end
end
