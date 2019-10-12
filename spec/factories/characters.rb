FactoryBot.define do
  factory :character do
    sequence(:name) { |i| "Name#{i}" }
    level { 60 }
    association :user
    association :world

    trait :human_warrior do
      association :race, :human
      association :character_class, :warrior
    end
  end
end
