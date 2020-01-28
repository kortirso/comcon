class AddBooleanToCheckEquipment < ActiveRecord::Migration[5.2]
  def change
    add_column :characters, :item_level_calculated, :boolean, null: false, default: false
  end
end
