module Api
  module V1
    class SubscribesController < Api::V1::BaseController
      before_action :find_event, only: %i[create]
      before_action :find_subscribe, only: %i[update]
      before_action :find_user_subscribe, only: %i[create_comment]

      def create
        authorize! @event, with: SubscribePolicy, context: { status: params[:subscribe][:status] }
        perform_subscribe(subscribe_params, 201)
      end

      def update
        authorize! @subscribe, context: { status: params[:subscribe][:status] || :no_status_change }
        perform_subscribe(@subscribe.attributes.merge(update_subscribe_params.merge(character: @subscribe.character, event: @subscribe.event)), 200)
      end

      private

      def find_event
        @event = Event.find_by(id: params[:subscribe][:event_id])
        render_error('Object is not found') if @event.nil?
      end

      def find_subscribe
        @subscribe = Subscribe.find_by(id: params[:id])
        render_error('Object is not found') if @subscribe.nil?
      end

      def find_user_subscribe
        @subscribe = Current.user.subscribes.find_by(id: params[:id])
        render_error('Object is not found') if @subscribe.nil?
      end

      def perform_subscribe(options, status)
        subscribe_form = SubscribeForm.new(options)
        if subscribe_form.persist?
          render json: subscribe_form.subscribe, status: status
        else
          render json: { result: 'Failed' }, status: 409
        end
      end

      def subscribe_params
        h = update_subscribe_params.to_h
        h[:event] = @event
        h[:character] = Current.user.characters.find_by(id: params[:subscribe][:character_id])
        h
      end

      def update_subscribe_params
        params.require(:subscribe).permit(:status, :comment, :for_role)
      end
    end
  end
end
