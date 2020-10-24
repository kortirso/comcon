# frozen_string_literal: true

# Update time offset
class UpdateTimeOffset
  include Interactor

  # required context
  # context.timeable
  # context.value
  def call
    time_offset = TimeOffset.find_by(timeable: context.timeable)
    return if time_offset.nil?

    time_offset_form = TimeOffsetForm.new(time_offset.attributes.merge(value: context.value == '' ? nil : context.value))
    if time_offset_form.persist?
      context.time_offset = time_offset_form.time_offset
    else
      context.fail!(message: time_offset_form.errors.full_messages)
    end
  end
end
