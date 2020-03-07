# frozen_string_literal: true

# Update bank cells
class UpdateBankCellsService
  attr_reader :bank, :existed_bank_cell_items, :cell_items, :cell_item_uids

  def initialize(bank:)
    @bank = bank
    @existed_bank_cell_items = bank.bank_cells.pluck(:item_uid, :bag_number)
  end

  def call(cells_info:)
    calculate_cell_items(cells_info: cells_info)
    handle_cell_items
    delete_removed_bank_cells
  rescue
    nil
  end

  private

  def calculate_cell_items(cells_info:)
    result = {}
    cells_info.each do |data|
      cell_info = data[1..-2].split(',')
      if result.key?(cell_info[0].to_i)
        if result[cell_info[0].to_i].key?(cell_info[2].to_i)
          result[cell_info[0].to_i][cell_info[2].to_i] += cell_info[3].to_i
        else
          result[cell_info[0].to_i][cell_info[2].to_i] = cell_info[3].to_i
        end
      else
        result[cell_info[0].to_i] = { cell_info[2].to_i => cell_info[3].to_i }
      end
    end
    @cell_items = result
  end

  def handle_cell_items
    cell_items.each do |bag_number, bag_items|
      bag_items.each do |key, value|
        handle_cell_item(item_uid: key, amount: value, bag_number: bag_number)
      end
    end
  end

  def handle_cell_item(item_uid:, amount:, bag_number:)
    params =
      if existed_bank_cell_items.include?([item_uid, bag_number])
        bank_cell = BankCell.find_by(bank_id: bank.id, item_uid: item_uid, bag_number: bag_number)
        bank_cell.attributes.merge(bank: bank, amount: amount, game_item: bank_cell.game_item)
      else
        { bank: bank, item_uid: item_uid, amount: amount, game_item: GameItem.find_by(item_uid: item_uid), bag_number: bag_number }
      end
    BankCellForm.new(params).persist?
  end

  def delete_removed_bank_cells
    existed_bank_cell_items.each do |item|
      next if cell_items.key?(item[1]) && cell_items[item[1]].key?(item[0])
      BankCell.find_by(bank_id: bank.id, bag_number: item[1], item_uid: item[0]).destroy
    end
  end
end
