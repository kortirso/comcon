class CreateProfessions < ActiveRecord::Migration[5.2]
  def change
    create_table :professions do |t|
      t.jsonb :name, null: false, default: { en: '', ru: '' }
      t.boolean :main, null: false, default: true
      t.timestamps
    end
    add_index :professions, :name, using: :gin
  end
end
