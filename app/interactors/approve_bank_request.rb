# Approve bank request
class ApproveBankRequest
  include Interactor

  # required context
  # context.bank_request
  # context.provided_amount
  def call
    bank_request = context.bank_request
    change_amount = context.provided_amount.to_i.positive? ? context.provided_amount.to_i : bank_request.requested_amount
    bank_cell = BankCell.find_by(bank: bank_request.bank, game_item: bank_request.game_item)
    context.fail!(message: 'Bank cell does not exist') if bank_cell.nil?
    context.fail!(message: 'Too many items') if bank_cell.amount < change_amount
    ActiveRecord::Base.transaction do
      bank_request.update!(status: 2)
      bank_cell.update!(amount: bank_cell.amount - change_amount)
    end
    context.bank_cell = bank_cell
  rescue
    context.fail!(message: 'Bank request can not be updated')
  end
end
