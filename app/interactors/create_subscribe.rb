# Create Subscribe
class CreateSubscribe
  include Interactor

  # required context
  # context.event
  # context.character
  # context.status
  def call
    subscribe_form = SubscribeForm.new(event: context.event, character: context.character, status: context.status)
    subscribe_form.persist?
  end
end
