class GuildInviteSerializer < ActiveModel::Serializer
  attributes :id, :from_guild, :status
  belongs_to :guild, serializer: GuildSerializer
  belongs_to :character, serializer: CharacterCrafterSerializer
end
