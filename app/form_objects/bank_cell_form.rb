# Represents form object for BankCell model
class BankCellForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :item_uid, Integer
  attribute :amount, Integer, default: 1
  attribute :bag_number, Integer
  attribute :bank, Bank
  attribute :game_item, GameItem

  validates :item_uid, :amount, :bank, presence: true
  validates :amount, numericality: { greater_than: 0 }

  attr_reader :bank_cell

  def persist?
    return false unless valid?
    @bank_cell = id ? BankCell.find_by(id: id) : BankCell.new
    @bank_cell.attributes = attributes.except(:id)
    @bank_cell.save
    true
  end
end
