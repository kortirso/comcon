# Update bank cells
class UpdateBankCellsService
  attr_reader :bank, :existed_bank_cell_item_uids, :cell_items, :cell_item_uids

  def initialize(bank:)
    @bank = bank
    @existed_bank_cell_item_uids = bank.bank_cells.pluck(:item_uid)
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
      if result.key?(cell_info[2].to_i)
        result[cell_info[2].to_i] += cell_info[3].to_i
      else
        result[cell_info[2].to_i] = cell_info[3].to_i
      end
    end
    @cell_items = result
    @cell_item_uids = result.keys.map(&:to_i)
  end

  def handle_cell_items
    cell_items.each { |key, value| handle_cell_item(item_uid: key, amount: value) }
  end

  def handle_cell_item(item_uid:, amount:)
    params =
      if existed_bank_cell_item_uids.include?(item_uid)
        bank_cell = BankCell.find_by(bank_id: bank.id, item_uid: item_uid)
        bank_cell.attributes.merge(bank: bank, amount: amount, game_item: bank_cell.game_item)
      else
        { bank: bank, item_uid: item_uid, amount: amount, game_item: GameItem.find_by(item_uid: item_uid) }
      end
    BankCellForm.new(params).persist?
  end

  def delete_removed_bank_cells
    result_ids = []
    existed_bank_cell_item_uids.each do |item_uid|
      next if cell_item_uids.include?(item_uid)
      result_ids.push(item_uid)
    end
    BankCell.where(item_uid: result_ids).destroy_all
  end
end
