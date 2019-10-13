FactoryBot.define do
  factory :guild do
    sequence(:name) { |i| "Name#{i}" }
    association :world
    association :fraction
  end
end
