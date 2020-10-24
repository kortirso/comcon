# frozen_string_literal: true

class StaticMemberSerializer < ActiveModel::Serializer
  attributes :id, :static_id
  belongs_to :character, serializer: CharacterCrafterSerializer
end
