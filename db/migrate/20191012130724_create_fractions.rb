class CreateFractions < ActiveRecord::Migration[5.2]
  def change
    create_table :fractions do |t|
      t.jsonb :name, null: false, default: { en: '', ru: '' }
      t.timestamps
    end
    add_index :fractions, :name, using: :gin
  end
end
