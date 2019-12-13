# Represents guild banks
class Bank < ApplicationRecord
  belongs_to :guild

  has_many :bank_cells, dependent: :destroy
  has_many :bank_requests, dependent: :destroy
end
