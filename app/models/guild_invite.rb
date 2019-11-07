# Represents invite to guild and requests for guild membership
class GuildInvite < ApplicationRecord
  belongs_to :guild
  belongs_to :character
end
