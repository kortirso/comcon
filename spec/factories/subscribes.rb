FactoryBot.define do
  factory :subscribe do
    association :event
    association :character
  end
end
