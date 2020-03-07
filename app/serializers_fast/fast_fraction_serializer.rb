# frozen_string_literal: true

class FastFractionSerializer
  include FastJsonapi::ObjectSerializer

  set_type :fraction
  attributes :name
end
