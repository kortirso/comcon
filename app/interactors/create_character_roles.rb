# Create CharacterRoles
class CreateCharacterRoles
  include Interactor

  # required context
  # context.character_id
  # context.character_role_params
  def call
    context.character_role_params['roles'].each do |role_id, value|
      if value == '1'
        CharacterRole.create(character_id: context.character_id, role_id: role_id.to_i, main: context.character_role_params['main_role_id'] == role_id)
      elsif value == '0'
        character_role = CharacterRole.find_by(character_id: context.character_id, role_id: role_id.to_i)
        if character_role.nil?
          CharacterRole.create(character_id: context.character_id, role_id: role_id.to_i, main: true) if context.character_role_params['main_role_id'] == role_id
        else
          character_role.destroy
        end
      end
    end
  end
end
