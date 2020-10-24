# frozen_string_literal: true

FactoryBot.define do
  factory :character_profession do
    association :character
    association :profession
  end
end
