FactoryBot.define do
  factory :character do
    sequence(:name) { |i| "Name#{i}" }
    level { 60 }
    association :user
    association :world
    association :race, :human
    association :character_class, :paladin

    trait :human_warrior do
      association :race, :human
      association :character_class, :warrior
    end

    trait :orc do
      association :race, :orc
    end
  end
end
