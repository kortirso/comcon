class ChangeTimeOffset < ActiveRecord::Migration[5.2]
  def change
    add_column :time_offsets, :timeable_id, :integer
    add_column :time_offsets, :timeable_type, :string
    add_index :time_offsets, [:timeable_id, :timeable_type]

    TimeOffset.all.each do |time_offset|
      time_offset.update(timeable_id: time_offset.user_id, timeable_type: 'User')
    end

    remove_column :time_offsets, :user_id

    Guild.all.each { |guild| TimeOffset.create(timeable: guild, value: 3) }
  end
end
