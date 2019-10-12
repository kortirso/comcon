# base policy
class ApplicationPolicy < ActionPolicy::Base
  private

  def admin?
    user.is_admin?
  end
end
