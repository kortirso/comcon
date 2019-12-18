class GuildShowSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :slug, :locale
end
