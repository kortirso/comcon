# frozen_string_literal: true

# Create Subscribes
class CreateSubscribes
  include Interactor

  # required context
  # context.subscribeable
  def call
    subscribes = []
    subscribes << Subscribe.new(subscribeable: context.subscribeable, character: context.subscribeable.owner, status: 'signed')

    if %w[Guild Static].include?(context.subscribeable.eventable_type)
      object = context.subscribeable.eventable
      object.characters.where.not(id: context.subscribeable.owner.id).find_each do |character|
        subscribes << Subscribe.new(subscribeable: context.subscribeable, character: character, status: 'created')
      end
    end
    Subscribe.import subscribes
  end
end
