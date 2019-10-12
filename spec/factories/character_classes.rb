FactoryBot.define do
  factory :character_class do
    trait :warrior do
      name { { en: 'Warrior', ru: 'Воин' } }
    end
  end
end
