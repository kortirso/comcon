# frozen_string_literal: true

class FastRecipeSerializer
  include FastJsonapi::ObjectSerializer

  set_type :recipe
  attributes :name, :links, :skill, :profession_id
end
