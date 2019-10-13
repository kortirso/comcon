class AddEventableToEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :eventable_id, :integer
    add_column :events, :eventable_type, :string
    add_index :events, [:eventable_id, :eventable_type]

    remove_column :events, :access
  end
end
