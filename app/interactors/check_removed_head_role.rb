# frozen_string_literal: true

# Create what need to remove after deleting GM role from character
class CheckRemovedHeadRole
  include Interactor

  # required context
  # context.guild_role
  def call
    return if context.guild_role.name != 'gm'

    user = context.guild_role.character.user
    other_head_characters_of_user = user.characters.where.not(id: context.guild_role.character_id).joins(:guild_role).where(guild_roles: { name: 'gm' })
    return unless other_head_characters_of_user.empty?

    notification = Notification.find_by(event: 'guild_request_creation', status: 1)
    return if notification.nil?

    Delivery.where(deliveriable: user, notification: notification).destroy_all
  end
end
