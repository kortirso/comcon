# frozen_string_literal: true

FactoryBot.define do
  factory :character_class do
    trait :warrior do
      name { { en: 'Warrior', ru: 'Воин' } }
    end

    trait :shaman do
      name { { en: 'Shaman', ru: 'Шаман' } }
    end

    trait :paladin do
      name { { en: 'Paladin', ru: 'Паладин' } }
    end

    trait :druid do
      name { { en: 'Druid', ru: 'Друид' } }
    end
  end
end
