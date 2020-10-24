# frozen_string_literal: true

class SubscribeSerializer < ActiveModel::Serializer
  attributes :id, :status, :for_role, :comment, :character, :subscribeable_id, :subscribeable_type

  def character
    CharacterSubscriptionSerializer.new(object.character)
  end
end
