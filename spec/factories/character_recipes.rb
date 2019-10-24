FactoryBot.define do
  factory :character_recipe do
    association :recipe
    association :character_profession
  end
end
