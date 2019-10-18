class UsersController < ApplicationController
  before_action :is_admin?
  before_action :find_users, only: %i[index]
  before_action :find_user, only: %i[edit update destroy]

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

  private

  def find_users
    @users = User.order(id: :asc)
  end

  def find_user
    @user = User.find_by(id: params[:id])
    render_error('Object is not found') if @user.nil?
  end

  def user_params
    params.require(:user).permit(:role)
  end
end
