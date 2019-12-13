# Represents bank requests for items
class BankRequest < ApplicationRecord
  enum status: { send: 0, declined: 1, completed: 2 }, _prefix: :status

  belongs_to :bank
  belongs_to :game_item
  belongs_to :character, optional: true
end
