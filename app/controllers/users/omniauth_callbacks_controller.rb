module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    include CookiesHelper

    skip_before_action :set_current_user
    skip_before_action :save_current_path
    skip_before_action :authenticate_user!
    before_action :provides_callback

    def discord; end

    private

    def provides_callback
      I18n.locale = session[:omniauth_login_locale] || I18n.default_locale
      return redirect_to root_path, flash: { error: 'Access Error' } if request.env['omniauth.auth'].nil?
      user = Oauth.find_user(request.env['omniauth.auth'])
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
