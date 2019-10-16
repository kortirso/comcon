class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  prepend_view_path Rails.root.join('frontend')

  before_action :save_current_path
  before_action :authenticate_user!
  before_action :set_current_user
  before_action :set_locale
  skip_before_action :authenticate_user!, only: %i[catch_route_error]
  skip_before_action :set_current_user, only: %i[catch_route_error]

  authorize :user, through: :my_current_user

  rescue_from ActionPolicy::Unauthorized, with: :invalid_request

  def catch_route_error
    render_error('Route is not exist')
  end

  private

  def save_current_path
    session[:current_path] = request.url
  end

  def set_current_user
    Current.user = current_user
  end

  def my_current_user
    Current.user
  end

  def set_locale
    I18n.locale = params[:locale]
  end

  def json_request?
    request.format.json?
  end

  def invalid_request
    json_request? ? render_json_error('Forbidden') : render_html_error('Forbidden')
  end

  def render_error(message = 'Error')
    json_request? ? render_json_error(message) : render_html_error(message)
  end

  def render_json_error(message = 'Error')
    render json: { error: message }, status: 400
  end

  def render_html_error(message = 'Error')
    @message = message
    render template: 'shared/error', status: 404
  end
end
