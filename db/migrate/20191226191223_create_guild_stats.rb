class CreateGuildStats < ActiveRecord::Migration[5.2]
  def change
    add_column :guilds, :characters_count, :integer

    Guild.find_each { |guild| Guild.reset_counters(guild.id, :characters) }
  end
end
