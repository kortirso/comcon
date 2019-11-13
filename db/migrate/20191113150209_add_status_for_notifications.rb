class AddStatusForNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :status, :integer, null: false, default: 0
  end
end
