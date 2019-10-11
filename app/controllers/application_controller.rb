class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  prepend_view_path Rails.root.join('frontend')

  def catch_route_error
    render_not_found('Route is not exist')
  end

  private

  def render_not_found(message = 'Error')
    @message = message
    render template: 'shared/error', status: 404
  end
end
