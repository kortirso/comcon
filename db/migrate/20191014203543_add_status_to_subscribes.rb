class AddStatusToSubscribes < ActiveRecord::Migration[5.2]
  def change
    add_column :subscribes, :status, :string, null: false, default: 'unknown'

    Subscribe.all.each do |subscribe|
      status =
        if subscribe.signed? && subscribe.approved?
          'approved'
        elsif subscribe.signed? && !subscribe.approved?
          'signed'
        elsif !subscribe.signed? && !subscribe.approved?
          'rejected'
        end
      subscribe.update(status: status)
    end

    remove_column :subscribes, :signed
    remove_column :subscribes, :approved
  end
end
