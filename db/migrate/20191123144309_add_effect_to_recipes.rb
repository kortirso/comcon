class AddEffectToRecipes < ActiveRecord::Migration[5.2]
  def change
    add_column :recipes, :effect_name, :jsonb, default: { en: '', ru: '' }
    add_column :recipes, :effect_links, :jsonb, default: { en: '', ru: '' }
  end
end
