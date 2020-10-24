# frozen_string_literal: true

class WorldSerializer < ActiveModel::Serializer
  attributes :id, :name, :zone
end
