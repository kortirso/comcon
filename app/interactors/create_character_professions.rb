# frozen_string_literal: true

# Create links between characters and professions
class CreateCharacterProfessions
  include Interactor

  # required context
  # context.character_id
  # context.profession_params
  def call
    context.profession_params.each do |profession_id, value|
      next if value == '1'

      character_profession = CharacterProfession.find_by(character_id: context.character_id, profession_id: profession_id.to_i)
      next if character_profession.nil?

      character_profession.destroy
    end

    context.profession_params.each do |profession_id, value|
      next if value == '0'

      character_profession_form = CharacterProfessionForm.new(character: Character.find_by(id: context.character_id), profession: Profession.find_by(id: profession_id.to_i))
      character_profession_form.persist?
    end
  end
end
