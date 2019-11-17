FactoryBot.define do
  factory :static do
    sequence(:name) { |i| "Name#{i}" }
    privy { false }
    association :fraction
    association :world

    trait :guild do
      association :staticable, factory: :guild
    end

    trait :character do
      association :staticable, factory: :character
    end

    trait :privy do
      privy { true }
    end
  end
end
