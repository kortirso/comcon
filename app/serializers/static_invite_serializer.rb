class StaticInviteSerializer < ActiveModel::Serializer
  attributes :id, :static_id, :status, :static_name, :from_static
  belongs_to :character, serializer: CharacterCrafterSerializer

  def static_name
    object.static.name
  end
end
