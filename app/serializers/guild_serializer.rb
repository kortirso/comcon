class GuildSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :name, :slug, :fraction_id, :fraction_name, :world_id, :description

  def fraction_name
    object.fraction.name
  end
end
