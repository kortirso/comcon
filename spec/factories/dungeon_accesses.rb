FactoryBot.define do
  factory :dungeon_access do
    association :character, :human_warrior
    association :dungeon
  end
end
