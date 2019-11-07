module Users
  class OmniauthController < ApplicationController
    skip_before_action :save_current_path
    skip_before_action :authenticate_user!
    skip_before_action :set_current_user

    def localized
      session[:omniauth_login_locale] = I18n.locale
      redirect_to provider_path
    end

    private

    def provider_path
      case params[:provider]
        when 'discord' then user_discord_omniauth_authorize_path
        else root_path
      end
    end
  end
end
