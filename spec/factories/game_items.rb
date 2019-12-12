FactoryBot.define do
  factory :game_item do
    item_uid { 7 }
    level { 50 }
    icon_name { 'inv_ore_mithril_01' }
    name { { 'en' => 'Dark Iron Ore', 'ru' => 'Руда черного железа' } }
    association :game_item_quality
    association :game_item_category
    association :game_item_subcategory
  end
end
