class AddDescriptionToGuilds < ActiveRecord::Migration[5.2]
  def change
    add_column :guilds, :description, :text, null: false, default: ''
  end
end
