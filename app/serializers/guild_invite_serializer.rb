class GuildInviteSerializer < ActiveModel::Serializer
  attributes :id, :guild_id, :character_id, :from_guild, :status
end
