# frozen_string_literal: true

FactoryBot.define do
  factory :character_recipe do
    association :recipe
    association :character_profession
  end
end
