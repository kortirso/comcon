FactoryBot.define do
  factory :dungeon do
    sequence(:name) { |i| "Name#{i}" }
    raid { false }
    key_access { false }
    quest_access { false }
  end
end
