FactoryBot.define do
  factory :role do
    sequence(:name) { |i| { en: "Name#{i}", ru: "Роль#{i}" } }

    trait :tank do
      name { { en: 'Tank', ru: 'Танк' } }
    end

    trait :healer do
      name { { en: 'Healer', ru: 'Целитель' } }
    end

    trait :melee do
      name { { en: 'Melee', ru: 'Ближний бой' } }
    end

    trait :ranged do
      name { { en: 'Ranged', ru: 'Дальний бой' } }
    end
  end
end
