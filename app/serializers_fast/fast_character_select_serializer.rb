class FastCharacterSelectSerializer
  include FastJsonapi::ObjectSerializer

  set_type :character
  attributes :name
end
