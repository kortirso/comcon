FactoryBot.define do
  factory :event do
    sequence(:name) { |i| "Name#{i}" }
    event_type { 'instance' }
    start_time { DateTime.now + 1.hour }
    association :eventable, factory: :guild
    association :owner, factory: :character
    association :fraction, :alliance

    before(:create) do |event|
      world = event.eventable_type == 'World' ? event.eventable : event.eventable.world
      event.world_fraction = WorldFraction.find_or_create_by(world: world, fraction: event.fraction)
    end
  end
end
