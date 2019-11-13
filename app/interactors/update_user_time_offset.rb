# Update time offset for user
class UpdateUserTimeOffset
  include Interactor

  # required context
  # context.user
  # context.value
  def call
    time_offset = context.user.time_offset
    time_offset_form = TimeOffsetForm.new(time_offset.attributes.merge(user: time_offset.user, value: context.value == '' ? nil : context.value))
    if time_offset_form.persist?
      context.time_offset = time_offset_form.time_offset
    else
      context.fail!(message: time_offset_form.errors.full_messages)
    end
  end
end
