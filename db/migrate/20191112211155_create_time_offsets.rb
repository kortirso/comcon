class CreateTimeOffsets < ActiveRecord::Migration[5.2]
  def change
    create_table :time_offsets do |t|
      t.integer :user_id
      t.integer :value
      t.timestamps
    end
    add_index :time_offsets, :user_id
  end
end
