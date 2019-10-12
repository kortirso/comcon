class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  prepend_view_path Rails.root.join('frontend')

  before_action :save_current_path
  before_action :authenticate_user!
  before_action :set_current_user
  skip_before_action :authenticate_user!, only: %i[catch_route_error]
  skip_before_action :set_current_user, only: %i[catch_route_error]

  def catch_route_error
    render_not_found('Route is not exist')
  end

  private

  def save_current_path
    session[:current_path] = request.url
  end

  def set_current_user
    Current.user = current_user
  end

  def render_not_found(message = 'Error')
    @message = message
    render template: 'shared/error', status: 404
  end
end
