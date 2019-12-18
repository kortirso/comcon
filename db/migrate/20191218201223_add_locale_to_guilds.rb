class AddLocaleToGuilds < ActiveRecord::Migration[5.2]
  def change
    add_column :guilds, :locale, :string, null: false, default: 'ru'
  end
end
