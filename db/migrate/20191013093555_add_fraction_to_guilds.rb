class AddFractionToGuilds < ActiveRecord::Migration[5.2]
  def change
    add_column :guilds, :fraction_id, :integer
    add_index :guilds, :fraction_id
  end
end
