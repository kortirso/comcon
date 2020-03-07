# frozen_string_literal: true

# Create DeliveryParam
class CreateDeliveryParam
  include Interactor

  # required context
  # context.delivery_param_params
  # context.delivery
  def call
    delivery_param_form = DeliveryParamForm.new(params: check_integer_params, delivery: context.delivery)
    if delivery_param_form.persist?
      context.delivery_param = delivery_param_form.delivery_param
    else
      context.fail!(message: delivery_param_form.errors.full_messages)
    end
  end

  private

  def check_integer_params
    params = context.delivery_param_params['params']
    params['id'] = params['id'].to_i if params['id'].present?
    params
  end
end
