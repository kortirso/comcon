class AddDefaultGroupRoleForStatics < ActiveRecord::Migration[5.2]
  def change
    Static.all.each do |static|
      next if static.group_role.present?
      GroupRole.create(groupable: static, value: GroupRole.default)
    end
  end
end
