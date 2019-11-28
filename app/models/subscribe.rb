# Represents event subscribes
class Subscribe < ApplicationRecord
  enum status: { rejected: 0, unknown: 1, signed: 2, approved: 3, reserve: 4 }
  enum for_role: { tank: 0, healer: 1, dd: 2 }

  belongs_to :event
  belongs_to :character

  scope :status_order, -> { order status: :desc }
end
