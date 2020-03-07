# frozen_string_literal: true

# Transfering character
class ComplexTransferCharacter
  include Interactor::Organizer

  organize CreateCharacterRoles, CreateCharacterTransfer, ClearCharacterRoles
end
