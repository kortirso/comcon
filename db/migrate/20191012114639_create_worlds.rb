class CreateWorlds < ActiveRecord::Migration[5.2]
  def change
    create_table :worlds do |t|
      t.string :name, null: false, default: ''
      t.string :zone, null: false, default: ''
      t.timestamps
    end
    add_index :worlds, :name
  end
end
