module Api
  module V1
    class StaticInvitesController < Api::V1::BaseController
      before_action :find_static, only: %i[create]
      before_action :find_character, only: %i[create]
      before_action :check_static_member, only: %i[create]

      resource_description do
        short 'StaticInvite resources'
        formats ['json']
      end

      api :POST, '/v1/statics.json', 'Create static invite or member for guild members'
      error code: 401, desc: 'Unauthorized'
      error code: 409, desc: 'Conflict'
      def create
        authorize! @static, to: :management?
        if @static.for_guild? && @character.guild_id == @static.staticable_id
          create_static_member
        else
          create_static_invite
        end
      end

      private

      def find_static
        @static = Static.find_by(id: params[:static_invite][:static_id])
        render_error('Object is not found') if @static.nil?
      end

      def find_character
        @character = Character.find_by(id: params[:static_invite][:character_id])
        render_error('Object is not found') if @character.nil?
      end

      def check_static_member
        render json: { error: 'Static member already exists' }, status: 409 if StaticMember.where(static: @static, character: @character).exists?
      end

      def create_static_member
        result = CreateStaticMember.call(static: @static, character: @character)
        if result.success?
          render json: {
            character: CharacterCrafterSerializer.new(@character)
          }, status: 201
        else
          render json: { errors: result.message }, status: 409
        end
      end

      def create_static_invite
        static_invite_form = StaticInviteForm.new(static: @static, character: @character, status: 0)
        if static_invite_form.persist?
          render json: {
            invite: StaticInviteSerializer.new(static_invite_form.static_invite)
          }, status: 201
        else
          render json: { errors: static_invite_form.errors.full_messages }, status: 409
        end
      end
    end
  end
end
