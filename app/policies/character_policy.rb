# frozen_string_literal: true

# Character policies
class CharacterPolicy < ApplicationPolicy
  def update?
    record.user_id == user.id
  end
end
