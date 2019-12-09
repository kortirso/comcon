# Represents invites to statics
class StaticInvite < ApplicationRecord
  enum status: { send: 0, declined: 1 }, _prefix: :status

  belongs_to :static
  belongs_to :character

  scope :from_static, -> { where from_static: true }
  scope :from_character, -> { where from_static: false }
end
