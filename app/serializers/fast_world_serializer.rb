class FastWorldSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :name, :zone
end
