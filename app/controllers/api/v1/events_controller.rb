module Api
  module V1
    class EventsController < Api::V1::BaseController
      include Concerns::EventPresentable
      include Concerns::WorldCacher
      include Concerns::FractionCacher
      include Concerns::DungeonCacher

      before_action :find_start_of_month, only: %i[index]
      before_action :find_events, only: %i[index]
      before_action :find_event, only: %i[show update destroy subscribers]
      before_action :get_worlds_from_cache, only: %i[filter_values]
      before_action :get_fractions_from_cache, only: %i[filter_values]
      before_action :get_dungeons_from_cache, only: %i[filter_values event_form_values]

      api :GET, '/v1/events.json', 'Show events'
      error code: 401, desc: 'Unauthorized'
      def index
        render json: {
          events: ActiveModelSerializers::SerializableResource.new(@events, root: 'events', each_serializer: EventSerializer).as_json[:events]
        }, status: 200
      end

      api :GET, '/v1/events/:id.json', 'Show event info'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      def show
        render json: @event, status: 200
      end

      api :POST, '/v1/events.json', 'Create event'
      error code: 401, desc: 'Unauthorized'
      error code: 409, desc: 'Conflict'
      def create
        event_form = EventForm.new(event_params)
        if event_form.persist?
          CreateSubscribe.call(event: event_form.event, character: event_form.event.owner, status: 'signed')
          render json: event_form.event, status: 201
        else
          render json: { errors: event_form.errors.full_messages }, status: 409
        end
      end

      api :PATCH, '/v1/events/:id.json', 'Update event'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      error code: 409, desc: 'Conflict'
      def update
        authorize! @event
        event_form = EventForm.new(@event.attributes.merge(event_params))
        if event_form.persist?
          render json: event_form.event, status: 200
        else
          render json: { errors: event_form.errors.full_messages }, status: 409
        end
      end

      api :DELETE, '/v1/events/:id.json', 'Delete event'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      def destroy
        authorize! @event
        @event.destroy
        render json: { result: 'Event is destroyed' }, status: 200
      end

      api :GET, '/v1/events/:id/subscribers.json', 'Show event subscribers'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      def subscribers
        authorize! @event
        render_event_characters(@event)
      end

      def filter_values
        render json: {
          worlds: @worlds_json,
          fractions: @fractions_json,
          characters: ActiveModelSerializers::SerializableResource.new(Current.user.characters, each_serializer: CharacterIndexSerializer).as_json[:characters],
          guilds: ActiveModelSerializers::SerializableResource.new(Current.user.guilds.includes(:fraction, :world), each_serializer: GuildSerializer).as_json[:guilds],
          dungeons: @dungeons_json
        }, status: 200
      end

      def event_form_values
        render json: {
          characters: ActiveModelSerializers::SerializableResource.new(Current.user.characters, each_serializer: CharacterIndexSerializer).as_json[:characters],
          dungeons: @dungeons_json
        }, status: 200
      end

      private

      def find_start_of_month
        @start_of_month = params[:year].present? && params[:month].present? ? DateTime.new(params[:year].to_i, params[:month].to_i, 1, 0, 0, 0) : DateTime.now.new_offset(0)
      end

      def find_events
        @events = Event.where('start_time >= ? AND start_time < ?', @start_of_month.beginning_of_month, @start_of_month.end_of_month).order(start_time: :asc)
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

      def event_params
        h = params.require(:event).permit(:name, :eventable_type, :hours_before_close, :description).to_h
        h[:start_time] = Time.at(params[:event][:start_time].to_i).utc
        h[:owner] = @event.present? ? @event.owner : Current.user.characters.find_by(id: params[:event][:owner_id])
        h[:dungeon] = Dungeon.find_by(id: params[:event][:dungeon_id])
        h
      end
    end
  end
end
