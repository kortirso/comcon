class AddFromStaticToStaticInvites < ActiveRecord::Migration[5.2]
  def change
    add_column :static_invites, :from_static, :boolean, null: false, default: true
  end
end
