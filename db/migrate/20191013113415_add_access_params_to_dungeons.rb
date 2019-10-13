class AddAccessParamsToDungeons < ActiveRecord::Migration[5.2]
  def change
    add_column :dungeons, :key_access, :boolean, null: false, default: false
    add_column :dungeons, :quest_access, :boolean, null: false, default: false
  end
end
