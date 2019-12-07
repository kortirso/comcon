class RemoveEventFromSubscribes < ActiveRecord::Migration[5.2]
  def change
    remove_column :subscribes, :event_id
  end
end
