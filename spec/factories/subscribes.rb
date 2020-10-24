# frozen_string_literal: true

FactoryBot.define do
  factory :subscribe do
    association :subscribeable, factory: :event
    association :character
  end
end
