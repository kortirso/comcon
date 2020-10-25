# frozen_string_literal: true

module Subscribes
  module ForEvent
    class CreateService
      prepend BasicService

      def call(event:)
        @event = event

        initialize_collections
        subscribe_owner_character
        subscribe_static_members if @event.eventable_type == 'Static'
        subscribe_guild_members if @event.eventable_type == 'Guild'
        create_subscribe_objects
      end

      private

      def initialize_collections
        @subscribes               = []
        @subscribed_character_ids = []
      end

      def subscribe_owner_character
        @subscribes << Subscribe.new(subscribeable: @event, character: @event.owner, status: 'signed')
        @subscribed_character_ids << @event.owner.id
      end

      def subscribe_static_members
        subscribe_static_characters
        subscribe_guild_manager_characters if @event.eventable.staticable_type == 'Guild'
      end

      def subscribe_static_characters
        @event.eventable.characters.where.not(id: @subscribed_character_ids).find_each do |character|
          @subscribes << Subscribe.new(subscribeable: @event, character: character, status: 'created')
          @subscribed_character_ids << character.id
        end
      end

      def subscribe_guild_manager_characters
        guild = @event.eventable.staticable
        guild.characters_with_leader_role.where.not(id: @subscribed_character_ids).find_each do |character|
          @subscribes << Subscribe.new(subscribeable: @event, character: character, status: 'hidden')
        end
      end

      def subscribe_guild_members
        @event.eventable.users.where.not(id: @event.owner.user_id).find_each do |user|
          character =
            Character
              .where(guild_id: @event.eventable_id, user: user.id)
              .order(main: :desc, level: :desc, item_level: :desc)
              .first
          @subscribes << Subscribe.new(subscribeable: @event, character: character, status: 'created')
        end
      end

      def create_subscribe_objects
        Subscribe.import @subscribes
      end
    end
  end
end
