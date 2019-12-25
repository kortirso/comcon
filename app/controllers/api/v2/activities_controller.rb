module Api
  module V2
    class ActivitiesController < Api::V1::BaseController
      before_action :find_guild, only: %i[create]
      before_action :find_activity, only: %i[show update]

      resource_description do
        short 'Activity resources'
        formats ['json']
      end

      api :GET, '/v1/activities/:id.json', 'Get activity info'
      error code: 401, desc: 'Unauthorized'
      error code: 404, desc: 'Not found'
      def show
        authorize! @activity.guild, with: GuildPolicy, to: :management?
        render json: { activity: FastActivitySerializer.new(@activity).serializable_hash }, status: 200
      end

      api :POST, '/v1/activities.json', 'Create activity'
      error code: 401, desc: 'Unauthorized'
      error code: 404, desc: 'Not found'
      error code: 409, desc: 'Conflict'
      def create
        authorize! @guild, with: GuildPolicy, to: :management?
        save_activity(params: activity_params.merge(id: nil, guild: @guild), status: 201)
      end

      api :PATCH, '/v1/activities/:id.json', 'Update activity'
      param :id, String, required: true
      error code: 401, desc: 'Unauthorized'
      error code: 404, desc: 'Not found'
      error code: 409, desc: 'Conflict'
      def update
        authorize! @activity.guild, with: GuildPolicy, to: :management?
        save_activity(params: @activity.attributes.symbolize_keys.merge(activity_params.merge(guild: @activity.guild)), status: 200)
      end

      private

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
          CreateActivityNotificationJob.perform_now(activity_id: activity_dry_form.activity.id) if status == 201
          render json: { activity: FastActivitySerializer.new(activity_dry_form.activity).serializable_hash }, status: status
        else
          render json: { errors: activity_dry_form.errors }, status: 409
        end
      end

      def activity_params
        params.require(:activity).permit(:title, :description).to_h.symbolize_keys
      end
    end
  end
end
