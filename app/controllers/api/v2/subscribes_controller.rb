# frozen_string_literal: true

module Api
  module V2
    class SubscribesController < Api::V1::BaseController
      before_action :find_closest_subscribes, only: %i[closest]
      before_action :find_subscribe, only: %i[destroy]

      def closest
        render json: {
          subscribes: FastSubscribeIndexSerializer.new(@subscribes).serializable_hash
        }, status: :ok
      end

      def destroy
        authorize! @subscribe, context: { status: :no_status_change }
        @subscribe.destroy
        render json: { result: 'Subscribe is deleted' }, status: :ok
      end

      private

      def find_closest_subscribes
        @subscribes = Subscribe.where(subscribeable_type: 'Event', character_id: Current.user.characters.ids).includes(:event, :character).where('events.start_time > ?', DateTime.now).order(start_time: :asc).references(:event)
      end

      def find_subscribe
        @subscribe = Subscribe.find_by(id: params[:id])
        render_error(t('custom_errors.object_not_found'), 404) if @subscribe.nil?
      end
    end
  end
end
