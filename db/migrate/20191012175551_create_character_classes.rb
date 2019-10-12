class CreateCharacterClasses < ActiveRecord::Migration[5.2]
  def change
    create_table :character_classes do |t|
      t.jsonb :name, null: false, default: { en: '', ru: '' }
      t.timestamps
    end
    add_index :character_classes, :name, using: :gin
  end
end
