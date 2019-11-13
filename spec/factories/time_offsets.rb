FactoryBot.define do
  factory :time_offset do
    value { nil }
    association :user
  end
end
