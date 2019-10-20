FactoryBot.define do
  factory :character_role do
    main { false }
    association :character
    association :role, :melee
  end
end
