class CreateCharacterProfessions < ActiveRecord::Migration[5.2]
  def change
    create_table :character_professions do |t|
      t.integer :character_id
      t.integer :profession_id
      t.timestamps
    end
    add_index :character_professions, [:character_id, :profession_id], unique: true
  end
end
