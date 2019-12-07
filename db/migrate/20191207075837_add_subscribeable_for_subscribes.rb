class AddSubscribeableForSubscribes < ActiveRecord::Migration[5.2]
  def change
    add_column :subscribes, :subscribeable_id, :integer
    add_column :subscribes, :subscribeable_type, :string
    add_index :subscribes, [:subscribeable_id, :subscribeable_type]

    Subscribe.all.each do |subscribe|
      subscribe.update(subscribeable_id: subscribe.event_id, subscribeable_type: 'Event')
    end
  end
end
