FactoryBot.define do
  factory :character_role do
    main { false }
    association :character
    association :role
  end
end
