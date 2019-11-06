module Api
  module V1
    class DeliveriesController < Api::V1::BaseController
      before_action :find_deliveriable, only: %i[create]

      api :POST, '/v1/deliveries.json', 'Create delivery'
      error code: 401, desc: 'Unauthorized'
      error code: 409, desc: 'Conflict'
      def create
        authorize! @deliveriable, with: DeliveryPolicy
        result = CreateDeliveryWithParams.call(delivery_params: delivery_params, delivery_param_params: delivery_param_params)
        if result.success?
          render json: result.delivery, status: 201
        else
          render json: { errors: result.message }, status: 409
        end
      end

      private

      def find_deliveriable
        @deliveriable = params[:delivery][:deliveriable_type].constantize.find_by(id: params[:delivery][:deliveriable_id])
        render_error('Object is not found') if @deliveriable.nil?
      end

      def delivery_params
        h = params.require(:delivery).permit(:deliveriable_id, :deliveriable_type, :delivery_type).to_h
        h[:notification] = Notification.find_by(id: params[:delivery][:notification_id])
        h
      end

      def delivery_param_params
        params.require(:delivery_param).permit(params: {})
      end
    end
  end
end
