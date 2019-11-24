class GuildSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :name, :slug, :fraction_id, :world_id
end
