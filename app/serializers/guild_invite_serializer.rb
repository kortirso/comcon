class GuildInviteSerializer < ActiveModel::Serializer
  attributes :id, :from_guild, :status
  belongs_to :guild, serializer: GuildIndexSerializer
  belongs_to :character, serializer: CharacterCrafterSerializer
end
