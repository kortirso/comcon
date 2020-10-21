# frozen_string_literal: true

module Api
  module V2
    class ActivitiesController < Api::V1::BaseController
      before_action :find_activities, only: %i[index]
      before_action :find_guild, only: %i[create]
      before_action :find_activity, only: %i[show update]

      def index
        render json: { activities: FastActivitySerializer.new(@activities).serializable_hash }, status: :ok
      end

      def show
        authorize! @activity.guild, with: GuildPolicy, to: :management?
        render json: { activity: FastActivitySerializer.new(@activity).serializable_hash }, status: :ok
      end

      def create
        authorize! @guild, with: GuildPolicy, to: :management?
        save_activity(params: activity_params.merge(id: nil, guild: @guild), status: :created)
      end

      def update
        authorize! @activity.guild, with: GuildPolicy, to: :management?
        save_activity(params: @activity.attributes.symbolize_keys.merge(activity_params.merge(guild: @activity.guild)), status: :ok)
      end

      private

      def find_activities
        @activities = Activity.where(guild_id: Current.user.guilds.ids).or(Activity.common).order(updated_at: :desc).includes(guild: :world)
        @activities = @activities.where('updated_at > ?', Time.at(params[:last_updated_at].to_i).utc)
      end

      def find_guild
        @guild = Guild.find_by(id: params[:activity][:guild_id])
        render_error(t('custom_errors.object_not_found'), 404) if @guild.nil?
      end

      def find_activity
        @activity = Activity.find_by(id: params[:id])
        render_error(t('custom_errors.object_not_found'), 404) if @activity.nil?
      end

      def save_activity(params:, status:)
        activity_dry_form = ActivityDryForm.call(params)
        if activity_dry_form.save
          CreateActivityNotificationJob.perform_later(activity_id: activity_dry_form.activity.id) if status == :created
          render json: { activity: FastActivitySerializer.new(activity_dry_form.activity).serializable_hash }, status: status
        else
          render json: { errors: activity_dry_form.errors }, status: :conflict
        end
      end

      def activity_params
        params.require(:activity).permit(:title, :description).to_h.symbolize_keys
      end
    end
  end
end
