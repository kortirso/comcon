# Represents specifics roles in guilds
class GuildRole < ApplicationRecord
  belongs_to :guild
  belongs_to :character
end
