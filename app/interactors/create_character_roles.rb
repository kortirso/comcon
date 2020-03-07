# frozen_string_literal: true

# Create CharacterRoles
class CreateCharacterRoles
  include Interactor

  # required context
  # context.character_id
  # context.character_role_params
  def call
    context.character_role_params['roles'].each do |role_id, value|
      if value == '1'
        CharacterRole.find_or_create_by(character_id: context.character_id, role_id: role_id.to_i) do |character_role|
          character_role.main = context.character_role_params['main_role_id'] == role_id
        end
      elsif value == '0'
        character_role = CharacterRole.find_by(character_id: context.character_id, role_id: role_id.to_i)
        next if character_role.nil?
        character_role.destroy
      end
    end

    character = Character.find_by(id: context.character_id)
    current_roles = character.roles.order(main: :desc).pluck(:name).map { |element| [element['en'], element['ru']] }
    character.update(current_roles: current_roles)
  end
end
