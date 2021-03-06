# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include CookiesHelper

  protect_from_forgery with: :exception
  prepend_view_path Rails.root.join('frontend')

  # rubocop: disabled Rails/LexicallyScopedActionFilter
  skip_before_action :verify_authenticity_token, only: %i[create update destroy catch_route_error]
  # rubocop: enabled Rails/LexicallyScopedActionFilter
  before_action :set_external_services_tag
  before_action :set_current_user
  before_action :save_current_path
  before_action :set_locale
  before_action :authenticate_user!
  before_action :email_confirmed?
  skip_before_action :authenticate_user!, only: %i[catch_route_error]
  skip_before_action :set_current_user, only: %i[catch_route_error]
  skip_before_action :email_confirmed?, only: %i[catch_route_error]

  authorize :user, through: :my_current_user

  rescue_from ActionPolicy::Unauthorized, with: :invalid_request

  def catch_route_error
    request.format = :html if request.format != :json
    render_error(t('custom_errors.route_not_found'), 400)
  end

  private

  def is_admin?
    return invalid_request unless Current.user.is_admin?

    true
  end

  def set_external_services_tag
    session[:external_services_tag] = false
  end

  def set_current_user
    Current.user = current_person_in_cookies
  end

  def save_current_path
    session[:current_path] = request.url
  end

  def my_current_user
    Current.user
  end

  def set_locale
    I18n.locale = params[:locale]
  end

  def allow_wowhead_script
    @wowhead = true
  end

  def email_confirmed?
    render_error(t('custom_errors.not_confirmed'), 401) unless current_user.confirmed?
  end

  def invalid_request
    render_error(t('custom_errors.forbidden'), 403)
  end

  def render_error(message='Error', status=400)
    respond_to do |type|
      type.html { render_html_error(message, status) }
      type.json { render_json_error(message, status) }
      type.all  { render nothing: true, status: status }
    end
  end

  def render_json_error(message='Error', status=400)
    render json: { error: message }, status: status
  end

  def render_html_error(message='Error', status=400)
    @message = message
    case status
    when 404 then render template: 'shared/404', status: :not_found
    when 403 then render template: 'shared/403', status: :forbidden
    when 401 then render template: 'shared/401', status: :unauthorized
    else render template: 'shared/default', status: :bad_request
    end
  end
end
