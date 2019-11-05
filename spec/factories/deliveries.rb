FactoryBot.define do
  factory :delivery do
    delivery_type { 0 }
    association :deliveriable, factory: :guild
    association :notification
  end
end
