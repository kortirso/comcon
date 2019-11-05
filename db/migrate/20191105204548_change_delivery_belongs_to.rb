class ChangeDeliveryBelongsTo < ActiveRecord::Migration[5.2]
  def change
    remove_column :deliveries, :guild_id
    add_column :deliveries, :deliveriable_id, :integer
    add_column :deliveries, :deliveriable_type, :string
    add_index :deliveries, [:deliveriable_id, :deliveriable_type, :notification_id], name: 'delivery_owner'
  end
end
