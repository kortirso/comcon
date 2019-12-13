FactoryBot.define do
  factory :game_item_quality do
    uid { 1 }
    name { { 'en' => 'Common', 'ru' => 'Обычный' } }
  end
end
