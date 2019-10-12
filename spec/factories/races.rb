FactoryBot.define do
  factory :race do
    trait :human do
      name { { en: 'Human', ru: 'Человек' } }
      association :fraction, :alliance
    end

    trait :orc do
      name { { en: 'Orc', ru: 'Орк' } }
      association :fraction, :horde
    end
  end
end
