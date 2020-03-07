# frozen_string_literal: true

# Create Guild
class CreateGuild
  include Interactor

  # required context
  # context.guild_params
  # context.character
  def call
    guild_form = GuildForm.new(context.guild_params.merge(world: context.character.world, fraction: context.character.race.fraction))
    if guild_form.persist?
      context.guild = guild_form.guild
    else
      context.fail!(message: guild_form.errors.full_messages)
    end
  end

  def rollback
    context.guild.destroy
  end
end
