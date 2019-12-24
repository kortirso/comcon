module Api
  module V2
    class ActivitiesController < Api::V1::BaseController
      before_action :find_guild, only: %i[create]

      resource_description do
        short 'Activity resources'
        formats ['json']
      end

      api :POST, '/v1/activities.json', 'Create activity'
      error code: 401, desc: 'Unauthorized'
      error code: 404, desc: 'Not found'
      error code: 409, desc: 'Conflict'
      def create
        authorize! @guild, with: GuildPolicy, to: :management?
        activity_dry_form = ActivityDryForm.call(activity_params.merge(id: nil, guild: @guild))
        if activity_dry_form.save
          render json: { activity: FastActivitySerializer.new(activity_dry_form.activity).serializable_hash }, status: 201
        else
          render json: { errors: activity_dry_form.errors }, status: 409
        end
      end

      private

      def find_guild
        @guild = Guild.find_by(id: params[:activity][:guild_id])
        render_error(t('custom_errors.object_not_found'), 404) if @guild.nil?
      end

      def activity_params
        params.require(:activity).permit(:title, :description).to_h.symbolize_keys
      end
    end
  end
end
