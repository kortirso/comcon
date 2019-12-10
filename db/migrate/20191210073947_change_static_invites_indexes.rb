class ChangeStaticInvitesIndexes < ActiveRecord::Migration[5.2]
  def change
    remove_index :static_invites, name: 'index_static_invites_on_static_id_and_character_id'
    add_index :static_invites, [:static_id, :character_id, :from_static], unique: true, name: 'static_invites_index'
  end
end
