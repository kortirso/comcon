class CreateDeliveries < ActiveRecord::Migration[5.2]
  def change
    create_table :deliveries do |t|
      t.integer :guild_id
      t.integer :notification_id
      t.integer :delivery_type, null: false, default: 0
      t.timestamps
    end
    add_index :deliveries, [:guild_id, :notification_id]
  end
end
