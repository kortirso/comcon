# frozen_string_literal: true

# Find character as gm for new guild
class FindCharacterForGm
  include Interactor

  # required context
  # context.user
  # context.owner_id
  def call
    user_character = context.user.characters.where(guild_id: nil).find_by(id: context.owner_id)
    context.fail!(message: I18n.t('custom_errors.character_in_guild')) if user_character.nil?
    context.character = user_character
  end
end
