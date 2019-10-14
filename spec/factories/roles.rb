FactoryBot.define do
  factory :role do
    sequence(:name) { |i| { en: "Name#{i}", ru: "Роль#{i}" } }
  end
end
