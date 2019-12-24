class FastStaticSelectSerializer
  include FastJsonapi::ObjectSerializer

  set_type :static
  attributes :name
end
