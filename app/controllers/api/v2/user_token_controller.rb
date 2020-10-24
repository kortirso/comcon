# frozen_string_literal: true

module Api
  module V2
    class UserTokenController < Api::V1::BaseController
      skip_before_action :authenticate, only: %i[create]

      def create
        user = auto_auth
        render json: JwtService.new.json_response(user: user), status: :ok
      rescue AuthFailure => e
        render json: { errors: e.message }, status: :unauthorized
      end

      private

      def auto_auth
        if params.key?(:email)
          database_auth
        elsif params.key?(:provider)
          omniauth_auth
        else
          raise AuthFailure, 'No auth strategy found'
        end
      end

      def database_auth
        email, password = params.require(%i[email password])
        user = User.find_by(email: email)
        if user.nil? || !user.valid_password?(password)
          raise AuthFailure, 'Authorization error'
        end

        user
      end

      def omniauth_auth
        provider, access_token = params.require(%i[provider access_token])
        profile = CheckProvider.new(provider: provider, access_token: access_token).call
        identity = Identity.find_by(uid: profile['id'], provider: provider)
        raise AuthFailure, 'Authorization error' if identity.nil?

        identity.user
      rescue StandardError
        raise AuthFailure, 'Authorization error'
      end
    end
  end
end
