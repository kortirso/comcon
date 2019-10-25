module Api
  module V1
    class SubscribesController < Api::V1::BaseController
      include Concerns::EventPresentable

      before_action :find_event, only: %i[create]
      before_action :find_subscribe, only: %i[update]

      def create
        authorize! @event, with: SubscribePolicy, context: { status: update_subscribe_params[:status] }
        perform_subscribe(subscribe_params)
      end

      def update
        authorize! @subscribe, context: { status: update_subscribe_params[:status] }
        perform_subscribe(@subscribe.attributes.merge(update_subscribe_params.merge(character: @subscribe.character, event: @subscribe.event)))
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

      def perform_subscribe(options)
        subscribe_form = SubscribeForm.new(options)
        if subscribe_form.persist?
          render_event_characters(subscribe_form.event)
        else
          render json: { result: 'Failed' }
        end
      end

      def subscribe_params
        h = update_subscribe_params.to_h
        h[:event] = @event
        h[:character] = Current.user.characters.find_by(id: params[:subscribe][:character_id])
        h
      end

      def update_subscribe_params
        params.require(:subscribe).permit(:status)
      end
    end
  end
end