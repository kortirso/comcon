# Create StaticMember
class CreateStaticMember
  include Interactor

  # required context
  # context.static
  # context.character
  def call
    static_member_form = StaticMemberForm.new(static: context.static, character: context.character)
    static_member_form.persist?
  end
end
