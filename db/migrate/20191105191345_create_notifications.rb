class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.jsonb :name, null: false, default: { en: '', ru: '' }
      t.string :event
      t.timestamps
    end
    add_index :notifications, :name, using: :gin
  end
end
