class EmailConfirmationsController < ApplicationController
  skip_before_action :set_current_user
  skip_before_action :save_current_path
  skip_before_action :authenticate_user!
  skip_before_action :email_confirmed?
  before_action :find_user, only: %i[index]
  before_action :check_token, only: %i[index]

  def index
    sign_in @user unless user_signed_in?
    redirect_to root_path
  end

  private

  def find_user
    @user = User.find_by(email: params[:email])
    render_error(t('custom_errors.object_not_found'), 404) if @user.nil?
  end

  def check_token
    result = ValidateUserEmail.call(user: @user, confirmation_token: params[:confirmation_token])
    render_error(result.message, 400) unless result.success?
  end
end
