class SubscribeSerializer < ActiveModel::Serializer
  attributes :id, :status, :for_role, :comment, :character

  def character
    CharacterSubscriptionSerializer.new(object.character)
  end
end
