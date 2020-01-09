module Api
  module V2
    class SubscribesController < Api::V1::BaseController
      before_action :find_subscribe, only: %i[destroy]

      resource_description do
        short 'Subscribe resources'
        formats ['json']
      end

      api :DELETE, '/v2/subscribes/:id.json', 'Delete subscribe'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      error code: 403, desc: 'Forbidden'
      error code: 404, desc: 'Not found'
      def destroy
        authorize! @subscribe, context: { status: :no_status_change }
        @subscribe.destroy
        render json: { result: 'Subscribe is deleted' }, status: 200
      end

      private

      def find_subscribe
        @subscribe = Subscribe.find_by(id: params[:id])
        render_error(t('custom_errors.object_not_found'), 404) if @subscribe.nil?
      end
    end
  end
end
