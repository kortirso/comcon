FactoryBot.define do
  factory :guild_role do
    sequence(:name) { |i| "Name#{i}" }
    association :guild
    association :character
  end
end
