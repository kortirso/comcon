# Represents invites to statics
class StaticInvite < ApplicationRecord
  enum status: { send: 0, declined: 1, approved: 2 }, _prefix: :status

  belongs_to :static
  belongs_to :character
end
