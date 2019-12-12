# Represents bank cells
class BankCell < ApplicationRecord
  belongs_to :bank
  belongs_to :game_item, optional: true
end
