# frozen_string_literal: true

# Create Delivery
class CreateDelivery
  include Interactor

  # required context
  # context.delivery_params
  def call
    delivery_form = DeliveryForm.new(context.delivery_params)
    if delivery_form.persist?
      context.delivery = delivery_form.delivery
    else
      context.fail!(message: delivery_form.errors.full_messages)
    end
  end

  def rollback
    context.delivery.destroy
  end
end
