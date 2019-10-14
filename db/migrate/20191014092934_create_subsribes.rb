class CreateSubsribes < ActiveRecord::Migration[5.2]
  def change
    create_table :subscribes do |t|
      t.integer :event_id
      t.integer :character_id
      t.boolean :signed, null: false, default: true
      t.boolean :approved, null: false, default: false
      t.timestamps
    end
    add_index :subscribes, [:event_id, :character_id], unique: true
  end
end
