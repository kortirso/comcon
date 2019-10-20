FactoryBot.define do
  factory :combination do
    association :character_class
    association :combinateable, factory: :role
  end
end
