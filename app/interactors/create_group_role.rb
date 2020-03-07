# frozen_string_literal: true

# Create GroupRole
class CreateGroupRole
  include Interactor

  # required context
  # context.groupable
  # context.group_roles
  def call
    group_role_form = GroupRoleForm.new(groupable_id: context.groupable.id, groupable_type: context.groupable.class.name, value: context.group_roles['group_roles'])
    if group_role_form.persist?
      context.group_role = group_role_form.group_role
    else
      context.fail!(message: group_role_form.errors.full_messages)
    end
  end
end
