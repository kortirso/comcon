class StaticMemberSerializer < ActiveModel::Serializer
  attributes :id, :static_id
  belongs_to :character, serializer: CharacterCrafterSerializer
end
