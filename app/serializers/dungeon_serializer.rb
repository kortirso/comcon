class DungeonSerializer < ActiveModel::Serializer
  attributes :id, :name, :raid, :key_access, :quest_access
end
