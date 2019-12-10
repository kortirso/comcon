module Api
  module V1
    class StaticInvitesController < Api::V1::BaseController
      before_action :find_invite_creator, only: %i[index]
      before_action :find_static, only: %i[create]
      before_action :find_character, only: %i[create]
      before_action :check_static_member, only: %i[create]
      before_action :find_static_invite, only: %i[destroy approve decline]

      resource_description do
        short 'StaticInvite resources'
        formats ['json']
      end

      api :GET, '/v1/static_invites.json', 'Get list of static_invites for static or character'
      error code: 401, desc: 'Unauthorized'
      def index
        authorize! @from_static, with: StaticInvitePolicy, context: { static: @invite_creator, character: @invite_creator }
        render json: (@invite_creator.is_a?(Static) ? @invite_creator.static_invites.includes(:character) : @invite_creator.static_invites.includes(:static)), status: 200
      end

      api :POST, '/v1/statics.json', 'Create static invite or member for guild members'
      error code: 401, desc: 'Unauthorized'
      error code: 409, desc: 'Conflict'
      def create
        authorize! params[:static_invite][:from_static], with: StaticInvitePolicy, to: :index?, context: { static: @static, character: @character }
        if @static.for_guild? && @character.guild_id == @static.staticable_id
          create_static_member
        else
          create_static_invite
        end
      end

      def destroy
        authorize! @static_invite.from_static.to_s, with: StaticInvitePolicy, to: :index?, context: { static: @static_invite.static, character: @static_invite.character }
        @static_invite.destroy
        render json: { result: 'Static invite is destroyed' }, status: 200
      end

      api :POST, '/v1/static_invites/:id/approve.json', 'Approve static invite'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      error code: 404, desc: 'Object is not found'
      def approve
        authorize! @static_invite.from_static.to_s, with: StaticInvitePolicy, to: :approve?, context: { static: @static_invite.static, character: @static_invite.character }
        ApproveStaticInvite.call(static_invite: @static_invite, static: @static_invite.static, character: @static_invite.character, status: 2)
        render json: { result: 'Character is added to the static' }, status: 200
      end

      api :POST, '/v1/static_invites/:id/decline.json', 'Decline static invite'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      error code: 404, desc: 'Object is not found'
      def decline
        authorize! @static_invite.from_static.to_s, with: StaticInvitePolicy, to: :approve?, context: { static: @static_invite.static, character: @static_invite.character }
        UpdateStaticInvite.call(static_invite: @static_invite, status: 1)
        render json: { result: 'Static invite is declined' }, status: 200
      end

      private

      def find_invite_creator
        if params[:static_id].present?
          @invite_creator = Static.find_by(id: params[:static_id])
          render_error(t('custom_errors.object_not_found'), 404) if @invite_creator.nil?
          @from_static = 'true'
        elsif params[:character_id].present?
          @invite_creator = Character.where(user_id: Current.user.id).find_by(id: params[:character_id])
          render_error(t('custom_errors.object_not_found'), 404) if @invite_creator.nil?
          @from_static = 'false'
        else
          render_error('Static ID or Character ID must be presented', 400)
        end
      end

      def find_static
        @static = Static.find_by(id: params[:static_invite][:static_id])
        render_error(t('custom_errors.object_not_found'), 404) if @static.nil?
      end

      def find_character
        @character = Character.find_by(id: params[:static_invite][:character_id])
        render_error(t('custom_errors.object_not_found'), 404) if @character.nil?
      end

      def check_static_member
        render json: { error: 'Static member already exists' }, status: 409 if StaticMember.where(static: @static, character: @character).exists?
      end

      def find_static_invite
        @static_invite = StaticInvite.find_by(id: params[:id])
        render_error(t('custom_errors.object_not_found'), 404) if @static_invite.nil?
      end

      def create_static_member
        result = CreateStaticMember.call(static: @static, character: @character)
        if result.success?
          render json: {
            member: StaticMemberSerializer.new(result.static_member)
          }, status: 201
        else
          render json: { errors: result.message }, status: 409
        end
      end

      def create_static_invite
        static_invite_form = StaticInviteForm.new(static: @static, character: @character, status: 0, from_static: params[:static_invite][:from_static])
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
