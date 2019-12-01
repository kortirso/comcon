class AddDefaultSettingsForEvents < ActiveRecord::Migration[5.2]
  def change
    Event.all.each do |event|
      next if event.group_role.present?
      GroupRole.create(groupable: event, value: GroupRole.default)
    end
  end
end
