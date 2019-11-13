module Api
  module V1
    class UserSettingsController < Api::V1::BaseController
      resource_description do
        short 'User settings resources'
        formats ['json']
      end

      api :GET, '/v1/user_settings.json', 'Get user settings'
      error code: 401, desc: 'Unauthorized'
      def index
        render json: {
          time_offset: TimeOffsetSerializer.new(Current.user.time_offset)
        }, status: 200
      end

      api :PATCH, '/v1/user_settings/update_settings.json', 'Update user settings'
      error code: 401, desc: 'Unauthorized'
      def update_settings
        UpdateUserTimeOffset.call(user: Current.user, value: user_settings_params[:time_offset][:value])
        render json: { result: 'User settings are updated' }, status: 200
      end

      private

      def user_settings_params
        params.require(:user_settings).permit(time_offset: {})
      end
    end
  end
end
