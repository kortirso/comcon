# Represents event subscribes
class Subscribe < ApplicationRecord
  #enum status: { rejected: 0, unknown: 1, signed: 2, approved: 3 }

  belongs_to :event
  belongs_to :character

  scope :approved, -> { where status: 'approved' }
  scope :signed, -> { where status: 'signed' }
  scope :rejected, -> { where status: 'rejected' }
  scope :unknown, -> { where status: 'unknown' }

  scope :status_order, -> { order status: :desc }
end
