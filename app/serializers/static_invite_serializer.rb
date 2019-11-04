class StaticInviteSerializer < ActiveModel::Serializer
  attributes :id, :static_id, :status
  belongs_to :character, serializer: CharacterCrafterSerializer
end
