# frozen_string_literal: true

# actions after character left guild
class CharacterLeftFromGuild
  include Interactor::Organizer

  organize RemoveGuildRole, RebuildGuildRoles
end
