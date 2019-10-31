FactoryBot.define do
  factory :event do
    sequence(:name) { |i| "Name#{i}" }
    event_type { 'instance' }
    start_time { DateTime.now + 1.hour }
    association :eventable, factory: :world
    association :owner, factory: :character
    association :fraction, :alliance
  end
end
