# frozen_string_literal: true

module Api
  module V2
    class EventsController < Api::V1::BaseController
      include Concerns::FractionCacher
      include Concerns::DungeonCacher
      include Concerns::UserCharactersCacher
      include Concerns::UserGuildsCacher
      include Concerns::UserStaticsCacher

      before_action :find_start_of_month, only: %i[index]
      before_action :find_events, only: %i[index]
      before_action :find_user_subscribes, only: %i[index]
      before_action :get_fractions_from_cache, only: %i[filter_values]
      before_action :get_dungeons_for_select_from_cache, only: %i[filter_values]
      before_action :get_user_characters_from_cache, only: %i[filter_values]
      before_action :get_user_guilds_from_cache, only: %i[filter_values]
      before_action :get_user_statics_from_cache, only: %i[filter_values]
      before_action :find_event, only: %i[subscribers]

      resource_description do
        short 'Event information resources'
        formats ['json']
      end

      api :GET, '/v2/events.json', 'Show events'
      error code: 401, desc: 'Unauthorized'
      def index
        render json: {
          events: FastEventIndexSerializer.new(@events, params: { subscribes: @subscribes }).serializable_hash
        }, status: :ok
      end

      api :GET, '/v2/events/filter_values.json', 'Values for events filter'
      error code: 401, desc: 'Unauthorized'
      def filter_values
        render json: {
          fractions: @fractions_json,
          characters: @user_characters_json,
          guilds: @user_guilds_json,
          statics: @user_statics_json,
          dungeons: @dungeons_json
        }, status: :ok
      end

      api :GET, '/v2/events/subscribers.json', 'Values for events filter'
      error code: 401, desc: 'Unauthorized'
      def subscribers
        authorize! @event, to: :show?
        subscribes = @event.subscribes.includes(character: %i[character_class guild])
        result = Rails.cache.fetch(Subscribe.cache_key(subscribes)) do
          FastSubscribeSerializer.new(subscribes).serializable_hash
        end
        render json: {
          subscribers: result
        }, status: :ok
      end

      private

      def find_start_of_month
        if params[:year].present? && params[:month].present? && params[:day].present? && params[:days].present?
          @start_of_period = DateTime.new(params[:year].to_i, params[:month].to_i, params[:day].to_i, 0, 0, 0)
          @end_of_period = @start_of_period + params[:days].to_i.days
        else
          time_now = Time.now.utc
          day_of_week = time_now.wday.zero? ? 6 : (time_now.wday - 1)
          @start_of_period = DateTime.parse((time_now - day_of_week.days).to_date.to_s)
          @end_of_period = @start_of_period + 7.days
        end
      end

      def find_events
        @events = find_available_events
        @events = @events.where('start_time > ? AND start_time <= ?', @start_of_period, @end_of_period).order(start_time: :asc).includes(:group_role)
        @events = @events.where(eventable_type: params[:eventable_type]) if params[:eventable_type].present?
        @events = @events.where(eventable_id: params[:eventable_id]) if params[:eventable_id].present?
        @events = @events.where(fraction_id: params[:fraction_id]) if params[:fraction_id].present?
        @events = @events.where(dungeon_id: params[:dungeon_id]) if params[:dungeon_id].present?
      end

      def find_available_events
        return Event.available_for_user(Current.user.id) unless params[:character_id]
        character = Current.user.characters.find_by(id: params[:character_id])
        character.present? ? Event.available_for_character(character.id) : Event.available_for_user(Current.user.id)
      end

      def find_event
        @event = Event.find_by(id: params[:id])
        render_error(t('custom_errors.object_not_found'), 404) if @event.nil?
      end

      def find_user_subscribes
        @subscribes = Subscribe.where(subscribeable: @events, character_id: Current.user.characters.ids).pluck(:subscribeable_id, :status)
      end
    end
  end
end
