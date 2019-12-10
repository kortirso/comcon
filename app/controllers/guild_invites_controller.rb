class GuildInvitesController < ApplicationController
  before_action :find_character, only: %i[find]

  def find; end

  private

  def find_character
    @user_characters = ActiveModelSerializers::SerializableResource.new(Character.where(user: Current.user, guild_id: nil).includes(race: :fraction), each_serializer: CharacterIndexSerializer).as_json[:characters]
  end
end
