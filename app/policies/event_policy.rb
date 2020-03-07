# frozen_string_literal: true

# Event policies
class EventPolicy < ApplicationPolicy
  def show?
    record.available_for_user?(user)
  end

  def edit?
    record.owner.user_id == user.id
  end
end
