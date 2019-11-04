# Create StaticMember
class CreateStaticMember
  include Interactor

  # required context
  # context.static
  # context.character
  def call
    static_member_form = StaticMemberForm.new(static: context.static, character: context.character)
    context.fail!(message: static_member_form.errors.full_messages) unless static_member_form.persist?
  end
end
