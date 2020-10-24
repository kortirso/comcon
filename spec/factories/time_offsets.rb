# frozen_string_literal: true

FactoryBot.define do
  factory :time_offset do
    value { nil }
    association :timeable, factory: :user
  end
end
