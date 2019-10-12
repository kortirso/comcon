class CreateRaces < ActiveRecord::Migration[5.2]
  def change
    create_table :races do |t|
      t.jsonb :name, null: false, default: { en: '', ru: '' }
      t.integer :fraction_id
      t.timestamps
    end
    add_index :races, :name, using: :gin
    add_index :races, :fraction_id
  end
end
