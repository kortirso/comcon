FactoryBot.define do
  factory :bank do
    sequence(:name) { |i| "Name#{i}" }
    coins { 100 }
    association :guild
  end
end
