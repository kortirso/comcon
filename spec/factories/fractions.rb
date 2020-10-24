# frozen_string_literal: true

FactoryBot.define do
  factory :fraction do
    trait :alliance do
      name { { en: 'Alliance', ru: 'Альянс' } }
    end

    trait :horde do
      name { { en: 'Horde', ru: 'Орда' } }
    end
  end
end
