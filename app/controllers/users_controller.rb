# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[reset_password change_password]
  skip_before_action :set_current_user, only: %i[restore_password reset_password new_password change_password]
  skip_before_action :authenticate_user!, only: %i[restore_password reset_password new_password change_password]
  skip_before_action :email_confirmed?, only: %i[restore_password reset_password new_password change_password]
  before_action :is_admin?, except: %i[restore_password reset_password new_password change_password]
  before_action :find_users, only: %i[index]
  before_action :find_user, only: %i[edit update destroy]
  before_action :find_user_for_reset, only: %i[reset_password]
  before_action :find_last_time_reset_password, only: %i[reset_password]
  before_action :find_user_for_change_password, only: %i[new_password change_password]
  before_action :check_reset_passwords, only: %i[change_password]

  def index; end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to users_path
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, status: :see_other
  end

  def restore_password; end

  def reset_password
    GenerateResetToken.call(user: @user)
    redirect_to root_path, flash: { success: t('custom_errors.reset_password.sent_email') }
  end

  def new_password; end

  def change_password
    if @user.update(password: user_password_params[:password], reset_password_token: nil)
      redirect_to root_path, flash: { success: t('custom_errors.reset_password.created_new_password') }
    else
      redirect_to new_password_users_path(email: params[:email], reset_password_token: params[:reset_password_token]), flash: { danger: @user.errors.full_messages[0] }
    end
  end

  private

  def find_users
    @users = User.order(id: :asc).includes(:identities)
  end

  def find_user
    @user = User.find_by(id: params[:id])
    render_error(t('custom_errors.object_not_found'), 404) if @user.nil?
  end

  def find_user_for_reset
    @user = User.find_by(email: params[:email])
    render_error(t('custom_errors.reset_password.user_not_exists'), 404) if @user.nil?
  end

  def find_last_time_reset_password
    return if @user.reset_password_token_sent_at.nil?
    return if DateTime.now - 1.hour >= @user.reset_password_token_sent_at
    render_error(t('custom_errors.reset_password.hour_limit'), 400)
  end

  def find_user_for_change_password
    return render_error(t('custom_errors.reset_password.token_invalid'), 400) unless params[:reset_password_token].present?
    @user = User.find_by(email: params[:email], reset_password_token: params[:reset_password_token])
    render_error(t('custom_errors.reset_password.user_not_exists'), 404) if @user.nil?
  end

  def check_reset_passwords
    if user_password_params[:password] != user_password_params[:password_confirmation]
      redirect_to new_password_users_path(email: params[:email], reset_password_token: params[:reset_password_token]), flash: { danger: t('custom_errors.reset_password.different_passwords') }
    end
  end

  def user_params
    params.require(:user).permit(:role)
  end

  def user_password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
