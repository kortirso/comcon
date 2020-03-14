# frozen_string_literal: true

# Create Subscribes
class CreateSubscribes
  include Interactor

  # required context
  # context.subscribeable
  def call
    subscribes = []
    subscribed_character_ids = []
    subscribed_character_ids << context.subscribeable.owner.id
    subscribes << Subscribe.new(subscribeable: context.subscribeable, character: context.subscribeable.owner, status: 'signed')

    if %w[Guild Static].include?(context.subscribeable.eventable_type)
      object = context.subscribeable.eventable
      object.characters.where.not(id: context.subscribeable.owner.id).find_each do |character|
        subscribed_character_ids << character.id
        subscribes << Subscribe.new(subscribeable: context.subscribeable, character: character, status: 'created')
      end
      # create hidden subscribes for guild managers
      if object.is_a?(Static) && object.staticable.is_a?(Guild)
        object.staticable.characters_with_leader_role.where.not(id: subscribed_character_ids).find_each do |character|
          subscribes << Subscribe.new(subscribeable: context.subscribeable, character: character, status: 'hidden')
        end
      end
    end
    Subscribe.import subscribes
  end
end
