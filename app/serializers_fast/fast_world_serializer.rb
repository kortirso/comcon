# frozen_string_literal: true

class FastWorldSerializer
  include FastJsonapi::ObjectSerializer

  set_type :world
  attributes :name, :zone
end
