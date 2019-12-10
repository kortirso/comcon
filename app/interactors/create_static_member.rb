# Create StaticMember
class CreateStaticMember
  include Interactor

  # required context
  # context.static
  # context.character
  def call
    static_member_form = StaticMemberForm.new(static: context.static, character: context.character)
    if static_member_form.persist?
      CreateSubscribe.call(subscribeable: context.static, character: context.character, status: 4)
      UpdateStaticLeftValue.call(group_role: context.static.group_role)
      context.static_member = static_member_form.static_member
    else
      context.fail!(message: static_member_form.errors.full_messages)
    end
  end

  def rollback
    context.static_member.destroy
  end
end
