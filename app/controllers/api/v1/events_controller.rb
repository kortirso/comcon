module Api
  module V1
    class EventsController < Api::V1::BaseController
      include EventPresentable
      include Concerns::WorldCacher
      include Concerns::FractionCacher

      before_action :find_start_of_month, only: %i[index]
      before_action :find_events, only: %i[index]
      before_action :find_event, only: %i[show]
      before_action :get_worlds_from_cache, only: %i[filter_values]
      before_action :get_fractions_from_cache, only: %i[filter_values]

      def index
        render json: {
          events: ActiveModelSerializers::SerializableResource.new(@events, root: 'events', each_serializer: EventSerializer).as_json[:events]
        }, status: 200
      end

      def show
        authorize! @event
        render_event_characters(@event)
      end

      def filter_values
        render json: {
          worlds: @worlds_json,
          fractions: @fractions_json,
          characters: ActiveModelSerializers::SerializableResource.new(Current.user.characters, each_serializer: CharacterIndexSerializer).as_json[:characters],
          guilds: ActiveModelSerializers::SerializableResource.new(Current.user.guilds.includes(:fraction, :world), each_serializer: GuildSerializer).as_json[:guilds]
        }
      end

      private

      def find_start_of_month
        @start_of_month = params[:year].present? && params[:month].present? ? DateTime.new(params[:year].to_i, params[:month].to_i, 1, 0, 0, 0) : DateTime.now.new_offset(0)
      end

      def find_events
        @events = Event.where('start_time >= ? AND start_time < ?', @start_of_month.beginning_of_month, @start_of_month.end_of_month)
        @events = @events.where(eventable_type: params[:eventable_type]) if params[:eventable_type].present?
        @events = @events.where(eventable_id: params[:eventable_id]) if params[:eventable_id].present?
        @events = @events.where(fraction_id: params[:fraction_id]) if params[:fraction_id].present?
        if params[:character_id].present?
          character = Current.user.characters.find_by(id: params[:character_id])
          @events = character.present? ? @events.available_for_character(character) : @events.available_for_user(Current.user)
        else
          @events = @events.available_for_user(Current.user)
        end
      end

      def find_event
        @event = Event.find_by(id: params[:id])
        render_error('Object is not found') if @event.nil?
      end
    end
  end
end
