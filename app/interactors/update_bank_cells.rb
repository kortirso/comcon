# Update bank cells
class UpdateBankCells
  include Interactor

  # required context
  # context.bank
  # context.cells_info
  def call
    UpdateBankCellsJob.perform_now(bank_id: context.bank.id, cells_info: context.cells_info)
  end
end
