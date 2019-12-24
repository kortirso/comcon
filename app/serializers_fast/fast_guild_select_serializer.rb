class FastGuildSelectSerializer
  include FastJsonapi::ObjectSerializer

  set_type :guild
  attributes :full_name
end
