class CreateDeliveryParams < ActiveRecord::Migration[5.2]
  def change
    create_table :delivery_params do |t|
      t.integer :delivery_id
      t.jsonb :params, null: false, default: {}
      t.timestamps
    end
    add_index :delivery_params, :delivery_id
    add_index :delivery_params, :params, using: :gin
  end
end
