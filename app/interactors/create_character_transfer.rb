# frozen_string_literal: true

# Create CharacterTransfer
class CreateCharacterTransfer
  include Interactor

  # required context
  # context.character_id
  def call
    character = Character.find_by(id: context.character_id)
    context.fail!(message: 'Character is not exists') if character.nil?
    CharacterTransfer.create(character: character, name: character.name, race: character.race, world: character.world, character_class: character.character_class)
  end
end
