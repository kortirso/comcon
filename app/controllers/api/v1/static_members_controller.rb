# frozen_string_literal: true

module Api
  module V1
    class StaticMembersController < Api::V1::BaseController
      before_action :find_static_member, only: %i[destroy]

      resource_description do
        short 'StaticMember resources'
        formats ['json']
      end

      def destroy
        authorize! @static_member.static, to: :edit?
        @static_member.destroy
        UpdateStaticLeftValue.call(group_role: @static_member.static.group_role)
        render json: { result: 'Static member is destroyed' }, status: :ok
      end

      private

      def find_static_member
        @static_member = StaticMember.find_by(id: params[:id])
        render_error(t('custom_errors.object_not_found'), 404) if @static_member.nil?
      end
    end
  end
end
