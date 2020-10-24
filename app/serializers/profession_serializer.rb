# frozen_string_literal: true

class ProfessionSerializer < ActiveModel::Serializer
  attributes :id, :name, :main, :recipeable
end
