FactoryBot.define do
  factory :static do
    sequence(:name) { |i| "Name#{i}" }
    association :fraction
    association :world

    trait :guild do
      association :staticable, factory: :guild
    end

    trait :character do
      association :staticable, factory: :character
    end
  end
end
