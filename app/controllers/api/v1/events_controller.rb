module Api
  module V1
    class EventsController < Api::V1::BaseController
      include Concerns::WorldCacher
      include Concerns::FractionCacher
      include Concerns::DungeonCacher

      before_action :find_start_of_month, only: %i[index]
      before_action :find_events, only: %i[index]
      before_action :find_event, only: %i[show edit update destroy subscribers user_characters]
      before_action :get_worlds_from_cache, only: %i[filter_values]
      before_action :get_fractions_from_cache, only: %i[filter_values]
      before_action :get_dungeons_from_cache, only: %i[filter_values event_form_values]

      resource_description do
        short 'Event information resources'
        formats ['json']
      end

      def_param_group :event_params do
        param :event, Hash do
          param :name, String, required: false, description: 'Event name'
          param :owner_id, String, required: true, description: 'Character ID'
          param :eventable_type, String, required: true, description: 'World/Guild/Static'
          param :eventable_id, String, required: true, description: 'Eventable ID'
          param :event_type, String, required: true, description: 'raid/instance/custom'
          param :hours_before_close, String, required: true, description: 'Hours before close, from 0 to 24'
          param :description, String, required: false, description: 'Description'
          param :start_time, String, required: true, description: 'Integer value of seconds'
          param :dungeon_id, String, required: false, description: ''
        end
      end

      api :GET, '/v1/events.json', 'Show events'
      error code: 401, desc: 'Unauthorized'
      def index
        render json: {
          events: ActiveModelSerializers::SerializableResource.new(@events, root: 'events', each_serializer: EventIndexSerializer).as_json[:events]
        }, status: 200
      end

      api :GET, '/v1/events/:id.json', 'Show event info'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      def show
        render json: { event: EventShowSerializer.new(@event) }, status: 200
      end

      api :POST, '/v1/events.json', 'Create event'
      param_group :event_params
      error code: 401, desc: 'Unauthorized'
      error code: 409, desc: 'Conflict'
      def create
        event_form = EventForm.new(event_params)
        if event_form.persist?
          CreateSubscribe.call(event: event_form.event, character: event_form.event.owner, status: 'signed')
          CreateEventNotificationJob.perform_now(event_id: event_form.event.id)
          render json: { event: EventEditSerializer.new(event_form.event) }, status: 201
        else
          render json: { errors: event_form.errors.full_messages }, status: 409
        end
      end

      api :GET, '/v1/events/:id/edit.json', 'Show event info for editing'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      def edit
        render json: { event: EventEditSerializer.new(@event) }, status: 200
      end

      api :PATCH, '/v1/events/:id.json', 'Update event'
      param :id, String, required: true
      param_group :event_params
      error code: 401, desc: 'Unauthorized'
      error code: 409, desc: 'Conflict'
      def update
        authorize! @event, to: :edit?
        event_form = EventForm.new(@event.attributes.merge(event_params))
        if event_form.persist?
          render json: { event: EventEditSerializer.new(event_form.event) }, status: 200
        else
          render json: { errors: event_form.errors.full_messages }, status: 409
        end
      end

      api :DELETE, '/v1/events/:id.json', 'Delete event'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      def destroy
        authorize! @event, to: :edit?
        @event.destroy
        render json: { result: 'Event is destroyed' }, status: 200
      end

      api :GET, '/v1/events/:id/subscribers.json', 'Show event subscribers'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      def subscribers
        authorize! @event, to: :show?
        render json: @event.subscribes.status_order.includes(character: %i[character_class guild main_roles]), status: 200
      end

      api :GET, '/v1/events/:id/user_characters.json', 'Show user characters who can subscribe for event'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      def user_characters
        authorize! @event, to: :show?
        render json: { user_characters: Current.user.available_characters_for_event(event: @event).pluck(:id, :name) }, status: 200
      end

      api :GET, '/v1/events/filter_values.json', 'Values for events filter'
      error code: 401, desc: 'Unauthorized'
      def filter_values
        render json: {
          worlds: @worlds_json,
          fractions: @fractions_json,
          characters: ActiveModelSerializers::SerializableResource.new(Current.user.characters, each_serializer: CharacterIndexSerializer).as_json[:characters],
          guilds: ActiveModelSerializers::SerializableResource.new(Current.user.guilds.includes(:world), each_serializer: GuildBaseSerializer).as_json[:guilds],
          statics: Current.user.statics.pluck(:id, :name),
          dungeons: @dungeons_json
        }, status: 200
      end

      api :GET, '/v1/events/filter_values.json', 'Values for event form'
      error code: 401, desc: 'Unauthorized'
      def event_form_values
        render json: {
          characters: ActiveModelSerializers::SerializableResource.new(Current.user.characters, each_serializer: CharacterIndexSerializer).as_json[:characters],
          dungeons: @dungeons_json,
          statics: user_statics
        }, status: 200
      end

      private

      def find_start_of_month
        if params[:year].present? && params[:month].present? && params[:day].present? && params[:days].present?
          @start_of_period = DateTime.new(params[:year].to_i, params[:month].to_i, params[:day].to_i, 0, 0, 0)
          @end_of_period = @start_of_period + params[:days].to_i.days
        else
          time_now = Time.now
          day_of_week = time_now.wday.zero? ? 6 : (time_now.wday - 1)
          @start_of_period = DateTime.parse((time_now - day_of_week.days).to_date.to_s)
          @end_of_period = @start_of_period + 7.days
        end
      end

      def find_events
        @events = Event.where('start_time > ? AND start_time <= ?', @start_of_period, @end_of_period).order(start_time: :asc)
        @events = @events.where(eventable_type: params[:eventable_type]) if params[:eventable_type].present?
        @events = @events.where(eventable_id: params[:eventable_id]) if params[:eventable_id].present?
        @events = @events.where(fraction_id: params[:fraction_id]) if params[:fraction_id].present?
        @events = @events.where(dungeon_id: params[:dungeon_id]) if params[:dungeon_id].present?
        if params[:subscribed] == 'true'
          @events = @events.where_user_subscribed(Current.user)
        end
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

      def user_statics
        Current.user.statics.map do |static|
          {
            'id' => static.id,
            'name' => static.name,
            'characters' => static.characters.where(user_id: Current.user.id).pluck(:id)
          }
        end
      end

      def event_params
        h = params.require(:event).permit(:name, :eventable_type, :eventable_id, :hours_before_close, :description).to_h
        h[:start_time] = Time.at(params[:event][:start_time].to_i).utc
        h[:owner] = @event.present? ? @event.owner : Current.user.characters.find_by(id: params[:event][:owner_id])
        h[:dungeon] = Dungeon.find_by(id: params[:event][:dungeon_id])
        h
      end
    end
  end
end
