FactoryBot.define do
  factory :profession do
    sequence(:name) { |i| { en: "Name#{i}", ru: "Профессия#{i}" } }

    trait :skinning do
      name { { en: 'Skinning', ru: 'Снятие шкур' } }
    end
  end
end
