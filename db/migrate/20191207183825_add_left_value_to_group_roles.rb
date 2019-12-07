class AddLeftValueToGroupRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :group_roles, :left_value, :jsonb
    add_index :group_roles, :left_value, using: :gin
  end
end
