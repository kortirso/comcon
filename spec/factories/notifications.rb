FactoryBot.define do
  factory :notification do
    sequence(:name) { |i| "Name#{i}" }
    status { 0 }
    event { 'guild_event_creation' }
  end
end
