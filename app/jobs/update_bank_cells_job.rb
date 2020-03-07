# frozen_string_literal: true

# Update bank cells
class UpdateBankCellsJob < ApplicationJob
  queue_as :default

  def perform(bank_id:, cells_info:)
    bank = Bank.find_by(id: bank_id)
    return if bank.nil?
    UpdateBankCellsService.new(bank: bank).call(cells_info: cells_info)
    GetGameItemsForBankCells.new.call
  end
end
