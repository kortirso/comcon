class FastDungeonSelectSerializer
  include FastJsonapi::ObjectSerializer

  set_type :dungeon
  attributes :name
end
