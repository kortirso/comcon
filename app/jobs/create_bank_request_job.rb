# frozen_string_literal: true

# Send notifications about creating bank request in guild
class CreateBankRequestJob < ApplicationJob
  queue_as :default

  def perform(bank_request_id:)
    bank_request = BankRequest.find_by(id: bank_request_id)
    return if bank_request.nil?
    notification = Notification.find_by(event: 'bank_request_creation', status: 0)
    return if notification.nil?
    guild_delivery = Delivery.find_by(deliveriable: bank_request.bank.guild, notification: notification)
    return if guild_delivery.nil?
    Notifies::CreateBankRequest.new.call(bank_request: bank_request)
  end
end
