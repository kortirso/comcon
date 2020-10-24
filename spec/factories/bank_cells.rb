# frozen_string_literal: true

FactoryBot.define do
  factory :bank_cell do
    item_uid { 11_370 }
    amount { 10 }
    association :bank
  end
end
