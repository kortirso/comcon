class FastEventIndexSerializer
  include FastJsonapi::ObjectSerializer

  set_type :event
  attributes :name, :slug, :description, :fraction_id, :dungeon_id, :event_type, :eventable_type, :eventable_id, :owner_id

  attribute :date do |object|
    object.start_time.strftime('%-d.%-m.%Y')
  end

  attribute :time do |object|
    {
      hours: object.start_time.strftime('%H').to_i,
      minutes: object.start_time.strftime('%M').to_i
    }
  end

  attribute :group_role do |object|
    object.group_role.value if object.group_role&.defined?
  end

  attribute :status do |object, params|
    subscribe = params[:subscribes].select { |element| element[0] == object.id }[0]
    subscribe[1] unless subscribe.nil?
  end
end
