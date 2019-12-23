# Approve bank request
class ClearCharacterRoles
  include Interactor

  # required context
  # context.character_id
  def call
    BankRequest.where(character_id: context.character_id).destroy_all
    GuildInvite.where(character_id: context.character_id).destroy_all
    GuildRole.where(character_id: context.character_id).destroy_all
    StaticInvite.where(character_id: context.character_id).destroy_all
    StaticMember.where(character_id: context.character_id).destroy_all
    Subscribe.where(character_id: context.character_id).destroy_all
  end
end
