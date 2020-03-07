# frozen_string_literal: true

# Confirm from static by character
class LeaveFromStatic
  include Interactor

  # required context
  # context.character
  # context.static
  def call
    StaticMember.find_by(static: context.static, character: context.character)&.destroy
    Subscribe.find_by(subscribeable: context.static, character: context.character)&.destroy
  end
end
