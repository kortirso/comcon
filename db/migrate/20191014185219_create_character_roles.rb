class CreateCharacterRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :character_roles do |t|
      t.integer :character_id
      t.integer :role_id
      t.boolean :main, null: false, default: false
      t.timestamps
    end
    add_index :character_roles, [:character_id, :role_id]
  end
end
