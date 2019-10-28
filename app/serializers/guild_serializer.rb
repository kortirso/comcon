class GuildSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :name, :slug
  belongs_to :fraction, serializer: FractionSerializer
  belongs_to :world, serializer: WorldSerializer
end
