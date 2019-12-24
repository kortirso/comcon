class FastFractionSerializer
  include FastJsonapi::ObjectSerializer

  set_type :fraction
  attributes :name
end
