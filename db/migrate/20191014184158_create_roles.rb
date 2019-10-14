class CreateRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :roles do |t|
      t.jsonb :name, null: false, default: { en: '', ru: '' }
      t.timestamps
    end
    add_index :roles, :name, using: :gin
  end
end
