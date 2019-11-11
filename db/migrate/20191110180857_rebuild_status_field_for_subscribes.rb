class RebuildStatusFieldForSubscribes < ActiveRecord::Migration[5.2]
  def change
    add_column :subscribes, :status_new, :integer, null: false, default: 2

    Subscribe.all.each do |subscribe|
      new_value =
        case subscribe.status
          when 'rejected' then 0
          when 'unknown' then 1
          when 'signed' then 2
          when 'approved' then 3
          else 1
        end

      subscribe.update(status_new: new_value)
    end

    remove_column :subscribes, :status
    rename_column :subscribes, :status_new, :status
  end
end
