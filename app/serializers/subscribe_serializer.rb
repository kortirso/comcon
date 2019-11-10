class SubscribeSerializer < ActiveModel::Serializer
  attributes :id, :status, :comment, :character

  def character
    CharacterSubscriptionSerializer.new(object.character)
  end
end
