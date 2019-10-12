module Users
  class RegistrationsController < Devise::RegistrationsController
    skip_before_action :save_current_path

    protected

    def after_sign_up_path_for(_resource)
      session[:current_path] || root_path
    end
  end
end
