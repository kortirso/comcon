module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    include CookiesHelper

    skip_before_action :set_external_services_tag
    skip_before_action :set_current_user, unless: :external_services_tag_is_true?
    skip_before_action :save_current_path
    skip_before_action :authenticate_user!
    skip_before_action :email_confirmed?
    before_action :provides_callback

    def discord; end

    private

    def external_services_tag_is_true?
      @attach ||= session[:external_services_tag] == true
    end

    def provides_callback
      I18n.locale = session[:omniauth_login_locale] || I18n.default_locale
      return redirect_to root_path, flash: { error: 'Access Error' } if request.env['omniauth.auth'].nil?
      return attach_oauth_to_account if external_services_tag_is_true?
      check_oauth
    end

    def attach_oauth_to_account
      return root_path unless user_signed_in?
      Oauth.auth_binding(auth: request.env['omniauth.auth'], user: current_user)
      redirect_to root_path
    end

    def check_oauth
      user = Oauth.auth_login(auth: request.env['omniauth.auth'])
      if user
        remember user
        sign_in user
        redirect_to root_path, event: :authentication
      else
        redirect_to root_path, flash: { manifesto_username: true }
      end
    end
  end
end
