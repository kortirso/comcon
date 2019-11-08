class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index]

  def index; end

  private

  def set_external_services_tag
    session[:external_services_tag] = true
  end
end
