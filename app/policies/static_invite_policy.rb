# StaticInvite policies
class StaticInvitePolicy < ApplicationPolicy
  authorize :static, :character

  def index?
    return user.any_static_role?(static) if record == 'true'
    character.user_id == user.id
  end
end
