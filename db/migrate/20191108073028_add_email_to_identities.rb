class AddEmailToIdentities < ActiveRecord::Migration[5.2]
  def change
    add_column :identities, :email, :string
    add_index :identities, [:uid, :provider]
  end
end
