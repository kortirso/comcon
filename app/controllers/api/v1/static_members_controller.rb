module Api
  module V1
    class StaticMembersController < Api::V1::BaseController
      before_action :find_static_member, only: %i[destroy]

      resource_description do
        short 'StaticMember resources'
        formats ['json']
      end

      def destroy
        authorize! @static_member.static, to: :management?
        @static_member.destroy
        render json: { result: 'Static member is destroyed' }, status: 200
      end

      private

      def find_static_member
        @static_member = StaticMember.find_by(id: params[:id])
        render_error('Object is not found') if @static_member.nil?
      end
    end
  end
end