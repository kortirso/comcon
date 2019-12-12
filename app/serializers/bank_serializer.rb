class BankSerializer < ActiveModel::Serializer
  attributes :id, :name, :coins
  has_many :bank_cells, serializer: BankCellSerializer
end
