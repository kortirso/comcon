class ChangeBelongsForStatics < ActiveRecord::Migration[5.2]
  def change
    remove_column :statics, :guild_id
    add_column :statics, :staticable_id, :integer
    add_column :statics, :staticable_type, :string
    add_index :statics, [:staticable_id, :staticable_type, :name], unique: true
  end
end
