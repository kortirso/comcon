class AddSlugToGuilds < ActiveRecord::Migration[5.2]
  def change
    add_column :guilds, :slug, :string, null: false, default: ''
    add_index :guilds, :slug
  end
end
