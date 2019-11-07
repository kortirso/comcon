class AddStatusToGuildInvites < ActiveRecord::Migration[5.2]
  def change
    add_column :guild_invites, :status, :integer, null: false, default: 0
  end
end
