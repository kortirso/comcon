# frozen_string_literal: true

class StaticsController < ApplicationController
  before_action :find_user_statics, only: %i[index]
  before_action :find_guild, only: %i[new]
  before_action :find_static_by_slug, only: %i[show edit destroy management]
  before_action :find_static_characters, only: %i[show]

  def index; end

  def show
    authorize! @static
  end

  def new
    authorize! @guild, with: StaticPolicy if @guild.present?
  end

  def edit
    authorize! @static
  end

  def destroy
    authorize! @static, to: :edit?
    @static.destroy
    redirect_to @static.staticable_type == 'Guild' ? statics_guild_path(@static.staticable.slug) : statics_path
  end

  def management
    authorize! @static, to: :edit?
  end

  def search; end

  private

  def find_user_statics
    @user_statics = Current.user.statics
    @user_static_invites = Current.user.static_invites
  end

  def find_guild
    return if params[:guild_id].blank?

    @guild = Guild.find_by(id: params[:guild_id])
    render_error(t('custom_errors.object_not_found'), 404) if @guild.nil?
  end

  def find_static_by_slug
    @static = Static.find_by(slug: params[:id])
    render_error(t('custom_errors.object_not_found'), 404) if @static.nil?
  end

  def find_static_characters
    @static_characters = ActiveModelSerializers::SerializableResource.new(@static.characters.includes(:character_class, :guild), each_serializer: CharacterSubscriptionSerializer).as_json[:characters].sort_by { |character| [Role::ROLE_VALUES[character[:roles][0]['en']], character[:character_class_name]['en'], - character[:level], character[:name]] }
  end
end
