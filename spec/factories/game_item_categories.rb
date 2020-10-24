# frozen_string_literal: true

FactoryBot.define do
  factory :game_item_category do
    uid { 7 }
    name { { 'en' => 'Trade Goods', 'ru' => 'Хозяйственные товары' } }
  end
end
