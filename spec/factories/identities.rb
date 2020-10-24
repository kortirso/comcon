# frozen_string_literal: true

FactoryBot.define do
  factory :identity do
    uid { 123 }
    provider { 'discord' }
    sequence(:email) { |i| "identity#{i}@gmail.com" }
    association :user
  end
end
