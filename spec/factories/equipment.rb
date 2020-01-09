FactoryBot.define do
  factory :equipment do
    item_uid { '' }
    ench_uid { '' }
    slot { 0 }
    association :character
  end
end
