FactoryBot.define do
  factory :notification do
    sequence(:name) { |i| "Name#{i}" }
    event { 'guild_event_creation' }
  end
end
