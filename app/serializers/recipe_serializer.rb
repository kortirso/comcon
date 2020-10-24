# frozen_string_literal: true

class RecipeSerializer < ActiveModel::Serializer
  attributes :id, :name, :links, :skill, :profession_id
end
