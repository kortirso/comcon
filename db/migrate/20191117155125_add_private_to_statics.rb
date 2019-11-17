class AddPrivateToStatics < ActiveRecord::Migration[5.2]
  def change
    add_column :statics, :privy, :boolean, null: false, default: true
  end
end
