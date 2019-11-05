FactoryBot.define do
  factory :delivery do
    delivery_type { 0 }
    association :guild
    association :notification
  end
end
