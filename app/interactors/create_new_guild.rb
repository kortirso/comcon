# Create new guild proces
class CreateNewGuild
  include Interactor::Organizer

  organize FindCharacterForGm, CreateGuild, CreateGm, CreateGuildRole
end
