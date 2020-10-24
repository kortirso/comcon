# frozen_string_literal: true

class DeliverySerializer < ActiveModel::Serializer
  attributes :id, :deliveriable

  def deliveriable
    return GuildIndexSerializer.new(object.deliveriable) if object.deliveriable_type == 'Guild'

    nil
  end
end
