module Api
  module V2
    class CharactersController < Api::V1::BaseController
      before_action :find_character, only: %i[transfer]

      resource_description do
        short 'Character resources'
        formats ['json']
      end

      api :PATCH, '/v1/characters/:id/transfer.json', 'Update character'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      error code: 404, desc: 'Not found'
      error code: 409, desc: 'Conflict'
      def transfer
        authorize! @character, to: :update?
        character_form = CharacterForm.new(@character.attributes.merge(character_params))
        if character_form.persist?
          character_form.character.character_roles.destroy_all
          ComplexTransferCharacter.call(character_id: character_form.character.id, character_role_params: character_role_params)
          render json: character_form.character, status: 200
        else
          render json: { errors: character_form.errors.full_messages }, status: 409
        end
      end

      private

      def find_character
        @character = Current.user.characters.find_by(id: params[:id])
        render_error(t('custom_errors.object_not_found'), 404) if @character.nil?
      end

      def character_params
        h = params.require(:character).permit(:name).to_h
        h[:race] = Race.find_by(id: params[:character][:race_id])
        h[:character_class] = CharacterClass.find_by(id: params[:character][:character_class_id])
        h[:world] = World.find_by(id: params[:character][:world_id])
        h[:world_fraction] = WorldFraction.find_by(world_id: params[:character][:world_id], fraction_id: h[:race]&.fraction_id)
        h[:guild] = nil
        h[:user] = Current.user
        h
      end

      def character_role_params
        params.require(:character).permit(:main_role_id, roles: {}).to_h
      end
    end
  end
end
