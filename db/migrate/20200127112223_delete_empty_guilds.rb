class DeleteEmptyGuilds < ActiveRecord::Migration[5.2]
  def change
    Guild.where(characters_count: 0).destroy_all
  end
end
