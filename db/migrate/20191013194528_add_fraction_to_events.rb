class AddFractionToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :fraction_id, :integer
    add_index :events, :fraction_id
  end
end
