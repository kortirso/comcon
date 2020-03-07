# frozen_string_literal: true

class FastDungeonSelectSerializer
  include FastJsonapi::ObjectSerializer

  set_type :dungeon
  attributes :name
end
