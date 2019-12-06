class AddAccessTokenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :token, :string
  end
end
