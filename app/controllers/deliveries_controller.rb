# frozen_string_literal: true

class DeliveriesController < ApplicationController
  before_action :find_deliveriable, only: %i[new]
  before_action :find_delivery, only: %i[destroy]

  def new
    authorize! @deliveriable, with: DeliveryPolicy
  end

  def destroy
    authorize! @delivery.deliveriable, with: DeliveryPolicy
    @delivery.destroy
    redirect_to @delivery.deliveriable_type == 'Guild' ? notifications_guild_path(@delivery.deliveriable.slug) : notifications_settings_path
  end

  private

  def find_deliveriable
    return render_error(t('custom_errors.object_not_found'), 404) if params[:deliveriable_type].blank? || params[:deliveriable_id].blank?

    @deliveriable = params[:deliveriable_type].constantize.find_by(id: params[:deliveriable_id])
    render_error(t('custom_errors.object_not_found'), 404) if @deliveriable.nil?
  end

  def find_delivery
    @delivery = Delivery.find_by(id: params[:id])
    render_error(t('custom_errors.object_not_found'), 404) if @delivery.nil?
  end
end
