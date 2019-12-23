# Delete StaticInvite
class DeleteStaticInvite
  include Interactor

  # required context
  # context.static
  # context.character
  def call
    StaticInvite.where(static: context.static, character: context.character).destroy_all
  end
end
