# BankRequest policies
class BankRequestPolicy < ApplicationPolicy
  def destroy?
    record.character.user_id == user.id
  end
end
