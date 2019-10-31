class AddDescriptionToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :description, :text, null: false, default: ''
  end
end
