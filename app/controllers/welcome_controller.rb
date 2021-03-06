# frozen_string_literal: true

class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :email_confirmed?

  def index
    redirect_to activities_path if Current.user.present? && Current.user.confirmed?
  end

  def donate; end

  def privacy; end

  private

  def set_external_services_tag
    session[:external_services_tag] = true
  end
end
