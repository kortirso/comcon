FactoryBot.define do
  factory :static do
    sequence(:name) { |i| "Name#{i}" }
    association :guild
  end
end
