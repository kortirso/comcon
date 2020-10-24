# frozen_string_literal: true

FactoryBot.define do
  factory :static_invite do
    from_static { true }
    association :static, :guild
    association :character
  end
end
