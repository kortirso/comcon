# frozen_string_literal: true

class FastSubscribeSerializer
  include FastJsonapi::ObjectSerializer

  set_type :subscribe
  attributes :id, :status, :for_role, :comment

  attribute :character do |object|
    FastCharacterSerializer.new(object.character).serializable_hash
  end
end
