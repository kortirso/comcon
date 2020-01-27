FactoryBot.define do
  factory :dungeon do
    sequence(:name) { |i| "Name#{i}" }
    raid { false }
  end
end
