class FastSubscribeIndexSerializer
  include FastJsonapi::ObjectSerializer

  set_type :subscribe
  attributes :status

  attribute :event do |object|
    {
      name: object.event.name,
      slug: object.event.slug,
      start_time: object.event.start_time.to_i
    }
  end

  attribute :character do |object|
    {
      name: object.character.name
    }
  end
end
