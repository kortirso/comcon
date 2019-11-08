module Users
  class SessionsController < Devise::SessionsController
    include CookiesHelper

    skip_before_action :set_current_user
    skip_before_action :save_current_path
    before_action :forget_user, only: :destroy

    private

    def forget_user
      Current.user = nil
      forget(current_user) if current_user.present?
    end

    protected

    def after_sign_in_path_for(_resource)
      session[:current_path] || root_path
    end
  end
end
