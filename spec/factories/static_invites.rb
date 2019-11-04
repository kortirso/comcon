FactoryBot.define do
  factory :static_invite do
    association :static, :guild
    association :character
  end
end
