# frozen_string_literal: true

module Api
  module V1
    class SubscribesController < Api::V1::BaseController
      before_action :find_subscribeable, only: %i[create]
      before_action :find_subscribe, only: %i[update]

      def create
        authorize! @subscribeable, with: SubscribePolicy, context: { status: params[:subscribe][:status] }
        perform_subscribe(subscribe_params, :created)
      end

      def update
        authorize! @subscribe, context: { status: params[:subscribe][:status] || :no_status_change }
        perform_subscribe(@subscribe.attributes.merge(update_subscribe_params.merge(character: @subscribe.character)), :ok)
      end

      private

      def find_subscribeable
        @subscribeable = params[:subscribe][:subscribeable_type].constantize.find_by(id: params[:subscribe][:subscribeable_id])
        render_error(t('custom_errors.object_not_found'), 404) if @subscribeable.nil?
      end

      def find_subscribe
        @subscribe = Subscribe.find_by(id: params[:id])
        render_error(t('custom_errors.object_not_found'), 404) if @subscribe.nil?
      end

      def perform_subscribe(options, status)
        subscribe_form = SubscribeForm.new(options)
        if subscribe_form.persist?
          UpdateStaticLeftValue.call(group_role: subscribe_form.subscribe.subscribeable.group_role) if subscribe_form.subscribe.subscribeable_type == 'Static'
          render json: {
            subscribe: FastSubscribeSerializer.new(subscribe_form.subscribe).serializable_hash
          }, status: status
        else
          render json: { result: 'Failed' }, status: :conflict
        end
      end

      def subscribe_params
        h = create_subscribe_params.to_h
        h[:character] = Character.find_by(id: params[:subscribe][:character_id])
        h
      end

      def create_subscribe_params
        params.require(:subscribe).permit(:status, :comment, :for_role, :subscribeable_id, :subscribeable_type)
      end

      def update_subscribe_params
        params.require(:subscribe).permit(:status, :comment, :for_role)
      end
    end
  end
end
