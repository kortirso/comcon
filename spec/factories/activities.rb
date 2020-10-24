# frozen_string_literal: true

FactoryBot.define do
  factory :activity do
    title { 'Title' }
    description { 'Description' }
    association :guild
  end
end
