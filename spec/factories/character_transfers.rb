FactoryBot.define do
  factory :character_transfer do
    sequence(:name) { |i| "Name#{i}" }
    association :world
    association :race, :human
    association :character_class, :paladin
    association :character
  end
end
