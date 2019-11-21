module Users
  class RegistrationsController < Devise::RegistrationsController
    skip_before_action :set_current_user
    skip_before_action :save_current_path
    skip_before_action :email_confirmed?
    before_action :save_omniauth_login_locale, only: :new

    private

    def save_omniauth_login_locale
      session[:omniauth_login_locale] = I18n.locale
    end

    protected

    def after_sign_up_path_for(_resource)
      session[:current_path] || root_path
    end
  end
end
