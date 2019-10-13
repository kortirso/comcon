FactoryBot.define do
  factory :event do
    sequence(:name) { |i| "Name#{i}" }
    event_type { 'instance' }
    start_time { DateTime.now + 1.day }
    access { 'guild' }
    association :owner, factory: :character
  end
end
