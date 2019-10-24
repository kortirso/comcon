FactoryBot.define do
  factory :recipe do
    sequence(:name) { |i| { en: "Name#{i}", ru: "Рецепт#{i}" } }
    sequence(:links) { |i| { en: "Link#{i}", ru: "Ссылка#{i}" } }
    skill { 300 }
    association :profession
  end
end
