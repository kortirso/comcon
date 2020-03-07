# frozen_string_literal: true

class FastCharacterSelectSerializer
  include FastJsonapi::ObjectSerializer

  set_type :character
  attributes :name
end
