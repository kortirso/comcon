class DeliveriesController < ApplicationController
  before_action :find_deliveriable, only: %i[new]
  before_action :find_delivery, only: %i[destroy]

  def new
    authorize! @deliveriable, with: DeliveryPolicy
  end

  def destroy
    authorize! @delivery.deliveriable, with: DeliveryPolicy
    @delivery.destroy
    redirect_to management_guild_path(@delivery.deliveriable.slug)
  end

  private

  def find_deliveriable
    return render_error('Object is not found') if !params[:deliveriable_type].present? || !params[:deliveriable_id].present?
    @deliveriable = params[:deliveriable_type].constantize.find_by(id: params[:deliveriable_id])
    render_error('Object is not found') if @deliveriable.nil?
  end

  def find_delivery
    @delivery = Delivery.find_by(id: params[:id])
    render_error('Object is not found') if @delivery.nil?
  end
end
