module Users
  class SessionsController < Devise::SessionsController
    include CookiesHelper

    skip_before_action :verify_authenticity_token
    skip_before_action :set_current_user
    skip_before_action :save_current_path
    skip_before_action :email_confirmed?
    before_action :save_omniauth_login_locale, only: :new
    before_action :forget_user, only: :destroy
    after_action :check_remember, only: :create

    private

    def save_omniauth_login_locale
      session[:omniauth_login_locale] = I18n.locale
    end

    def forget_user
      Current.user = nil
      forget(current_user) if current_user.present?
    end

    def check_remember
      remember(current_user) if current_user.present? && params[:user][:remember_me] == '1'
    end

    protected

    def after_sign_in_path_for(_resource)
      session[:current_path] || root_path
    end
  end
end
