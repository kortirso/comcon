class AddForRoleToSubscribes < ActiveRecord::Migration[5.2]
  def change
    add_column :subscribes, :for_role, :integer
  end
end
