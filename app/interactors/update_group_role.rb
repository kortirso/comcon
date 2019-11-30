# Update GroupRole
class UpdateGroupRole
  include Interactor

  # required context
  # context.group_role
  # context.group_roles
  def call
    group_role_form = GroupRoleForm.new(context.group_role.attributes.merge(value: context.group_roles['group_roles']))
    if group_role_form.persist?
      context.group_role = group_role_form.group_role
    else
      context.fail!(message: group_role_form.errors.full_messages)
    end
  end
end
