class GuildIndexSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :name, :slug
end
