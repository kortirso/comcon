class AddFieldsForStatics < ActiveRecord::Migration[5.2]
  def change
    add_column :statics, :description, :text, null: false, default: ''
    add_column :statics, :fraction_id, :integer
    add_column :statics, :world_id, :integer
    add_index :statics, :fraction_id
    add_index :statics, :world_id
  end
end
