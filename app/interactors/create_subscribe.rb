# Create Subscribe
class CreateSubscribe
  include Interactor

  # required context
  # context.subscribeable
  # context.character
  # context.status
  def call
    subscribe_form = SubscribeForm.new(subscribeable_id: context.subscribeable.id, subscribeable_type: context.subscribeable.class.name, character: context.character, status: context.status)
    subscribe_form.persist?
  end
end
