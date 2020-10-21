# frozen_string_literal: true

module Api
  module V1
    class UserSettingsController < Api::V1::BaseController
      def index
        render json: {
          time_offset: TimeOffsetSerializer.new(Current.user.time_offset)
        }, status: :ok
      end

      def update_settings
        UpdateTimeOffset.call(timeable: Current.user, value: user_settings_params[:time_offset][:value])
        render json: { result: 'User settings are updated' }, status: :ok
      end

      def update_password
        result = UpdateUserPassword.call(user: Current.user, user_password_params: user_password_params)
        if result.success?
          sign_in Current.user
          render json: { result: 'User password is updated' }, status: :ok
        else
          render json: { errors: result.message }, status: :conflict
        end
      end

      private

      def user_settings_params
        params.require(:user_settings).permit(time_offset: {})
      end

      def user_password_params
        params.require(:user_settings).permit(:password, :password_confirmation)
      end
    end
  end
end
