# frozen_string_literal: true

# Find or create bank
class FindOrCreateBank
  include Interactor

  # required context
  # context.guild
  # context.bank_data
  def call
    validate_bank_data!
    bank = Bank.find_by(guild: context.guild, name: context.bank_name)
    params = bank.nil? ? { guild: context.guild, name: context.bank_name, coins: context.bank_coins } : bank.attributes.merge(guild: bank.guild, coins: context.bank_coins)
    bank_form = BankForm.new(params)
    if bank_form.persist?
      context.bank = bank_form.bank
    else
      context.fail!(message: bank_form.errors.full_messages)
    end
  end

  private

  def validate_bank_data!
    decoded = Base64.decode64(context.bank_data).force_encoding('UTF-8').split(';')
    bank_info = decoded[0][1..-2].split(',')
    context.bank_name = bank_info[0]
    context.bank_coins = bank_info[1]
    context.cells_info = decoded[2..]
  rescue StandardError
    context.fail!(message: 'Invalid bank data')
  end
end
