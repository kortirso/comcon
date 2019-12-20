module Fast
  class WorldSerializer
    include FastJsonapi::ObjectSerializer

    attributes :id, :name, :zone
  end
end
