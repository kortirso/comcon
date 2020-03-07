# frozen_string_literal: true

class FastStaticSelectSerializer
  include FastJsonapi::ObjectSerializer

  set_type :static
  attributes :name
end
