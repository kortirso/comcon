# Define GM for new guild
class CreateGm
  include Interactor

  # required context
  # context.guild
  # context.character
  def call
    context.character.update(guild_id: context.guild.id)
  end

  def rollback
    context.character.update(guild_id: nil)
  end
end
