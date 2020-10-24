# frozen_string_literal: true

FactoryBot.define do
  factory :bank_request do
    requested_amount { 10 }
    status { 0 }
    association :bank
    association :game_item
  end
end
