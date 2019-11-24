class GuildShowSerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :description
end
