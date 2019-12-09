class DeleteEmptyGuildRoles < ActiveRecord::Migration[5.2]
  def change
    GuildRole.includes(:character).where('guild_roles.guild_id = characters.guild_id').references(:characters).destroy_all
  end
end
