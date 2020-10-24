# frozen_string_literal: true

FactoryBot.define do
  factory :world_fraction do
    association :world
    association :fraction, :alliance
  end
end
