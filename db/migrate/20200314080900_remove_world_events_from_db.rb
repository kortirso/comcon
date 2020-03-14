class RemoveWorldEventsFromDb < ActiveRecord::Migration[5.2]
  def change
    Event.where(eventable_type: 'World').destroy_all
  end
end
