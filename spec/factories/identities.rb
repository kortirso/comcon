FactoryBot.define do
  factory :identity do
    uid { 123 }
    provider { 'discord' }
    association :user
  end
end
