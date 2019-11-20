module Api
  module V1
    class BaseController < ApplicationController
      class AuthFailure < StandardError; end

      protect_from_forgery with: :null_session

      skip_before_action :save_current_path
      skip_before_action :authenticate_user!
      skip_before_action :set_current_user
      skip_before_action :email_confirmed?
      before_action :authenticate

      private

      def set_locale
        I18n.locale = params[:locale] || :en
      end

      def authenticate
        auto_auth
      rescue AuthFailure => ex
        Current.user = nil
        render json: { errors: ex.message }, status: 401
      end

      def auto_auth
        return user_auth_with_header if request.headers['Authorization']
        return user_auth_with_params if params.key?(:access_token)
        raise AuthFailure, 'There is no authorization token'
      end

      def user_auth_with_header
        user_auth(request.headers['Authorization'].split(' ')[-1])
      end

      def user_auth_with_params
        user_auth(params[:access_token])
      end

      def user_auth(access_token)
        check_token(access_token)
        find_user
        check_confirmation
        Current.user = @user
      end

      def check_token(access_token)
        @identifier = JwtService.new.decode(access_token: access_token)['user_id']
      rescue
        raise AuthFailure, 'Signature verification error'
      end

      def find_user
        @user = User.find_by(id: @identifier)
        raise AuthFailure, 'Authorization error' if @user.nil?
      end

      def check_confirmation
        raise AuthFailure, 'Your email is not confirmed' unless @user.confirmed?
      end
    end
  end
end
