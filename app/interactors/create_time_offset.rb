# frozen_string_literal: true

# Create time offset
class CreateTimeOffset
  include Interactor

  # required context
  # context.timeable
  # context.value
  def call
    time_offset_form = TimeOffsetForm.new(timeable_id: context.timeable.id, timeable_type: context.timeable.class.name, value: (context.value == '' ? nil : context.value))
    if time_offset_form.persist?
      context.time_offset = time_offset_form.time_offset
    else
      context.fail!(message: time_offset_form.errors.full_messages)
    end
  end
end
