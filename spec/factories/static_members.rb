# frozen_string_literal: true

FactoryBot.define do
  factory :static_member do
    association :static, :guild
    association :character
  end
end
