# Represents invite to guild and requests for guild membership
class GuildInvite < ApplicationRecord
  enum status: { send: 0, declined: 1 }, _prefix: :status

  belongs_to :guild
  belongs_to :character

  scope :from_guild, -> { where from_guild: true }
  scope :from_character, -> { where from_guild: false }
end
