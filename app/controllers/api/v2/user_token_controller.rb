module Api
  module V2
    class UserTokenController < Api::V1::BaseController
      skip_before_action :authenticate, only: %i[create]

      resource_description do
        short 'User token resources'
        formats ['json']
      end

      def_param_group :auth_params do
        param :email, String
        param :password, String
      end

      api :POST, '/v2/user_token.json', 'Authorization for user, returns token'
      param_group :auth_params
      example '{"user":{"id":"1", "email":""}, "access_token":"", "expires_at": 111}'
      error code: 401, desc: 'Unauthorized'
      def create
        user = auto_auth
        render json: JwtService.new.json_response(user: user), status: 200
      rescue AuthFailure => ex
        render json: { errors: ex.message }, status: 401
      end

      private

      def auto_auth
        if params.key?(:email)
          database_auth
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
    end
  end
end
