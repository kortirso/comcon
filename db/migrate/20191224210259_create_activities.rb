class CreateActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :activities do |t|
      t.integer :guild_id
      t.string :title
      t.text :description
      t.timestamps
    end
    add_index :activities, :guild_id
  end
end
