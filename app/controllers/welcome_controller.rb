class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index]
  skip_before_action :email_confirmed?, only: %i[index]

  def index
    redirect_to events_path if Current.user.present? && Current.user.confirmed?
  end

  private

  def set_external_services_tag
    session[:external_services_tag] = true
  end
end
