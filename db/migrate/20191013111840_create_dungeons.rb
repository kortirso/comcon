class CreateDungeons < ActiveRecord::Migration[5.2]
  def change
    create_table :dungeons do |t|
      t.jsonb :name, null: false, default: { en: '', ru: '' }
      t.boolean :raid, null: false, default: false
      t.timestamps
    end
    add_index :dungeons, :name, using: :gin
  end
end
