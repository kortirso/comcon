class UsersController < ApplicationController
  skip_before_action :set_current_user, only: %i[restore_password reset_password new_password change_password]
  skip_before_action :authenticate_user!, only: %i[restore_password reset_password new_password change_password]
  skip_before_action :email_confirmed?, only: %i[restore_password reset_password new_password change_password]
  before_action :is_admin?, except: %i[restore_password]
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
    redirect_to users_path, status: 303
  end

  def restore_password; end

  def reset_password
    GenerateResetToken.call(user_id: user_id)
  end

  def new_password; end

  def change_password
    @user.update(password: user_password_params[:password], reset_password_token: nil)
    redirect_to root_path
  end

  private

  def find_users
    @users = User.order(id: :asc).includes(:identities)
  end

  def find_user
    @user = User.find_by(id: params[:id])
    render_error('Object is not found') if @user.nil?
  end

  def find_user_for_reset
    @user = User.find_by(email: params[:email])
    render_error("User doesn't exist") if @user.nil?
  end

  def find_last_time_reset_password

  end

  def find_user_for_change_password
    return render_error('Token is incorrect') unless params[:reset_password_token].present?
    @user = User.find_by(email: params[:email], reset_password_token: params[:reset_password_token])
    render_error('User not found') if @user.nil?
  end

  def user_params
    params.require(:user).permit(:role)
  end
end
