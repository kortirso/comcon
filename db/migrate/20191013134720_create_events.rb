class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.integer :owner_id
      t.string :name
      t.string :event_type
      t.datetime :start_time
      t.string :access
      t.string :slug
      t.timestamps
    end
    add_index :events, :owner_id
    add_index :events, :slug, unique: true
  end
end
