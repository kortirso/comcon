module Users
  class SessionsController < Devise::SessionsController
    skip_before_action :save_current_path
    skip_before_action :set_current_user

    protected

    def after_sign_in_path_for(_resource)
      session[:current_path] || root_path
    end
  end
end
