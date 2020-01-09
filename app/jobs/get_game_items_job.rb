# Get game items info
class GetGameItemsJob < ApplicationJob
  queue_as :default

  def perform
    GetGameItemsForBankCells.new.call
  end
end
