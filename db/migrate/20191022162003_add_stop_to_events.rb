class AddStopToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :hours_before_close, :integer, null: false, default: 0
  end
end
