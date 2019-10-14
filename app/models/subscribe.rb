# Represents event subscribes
class Subscribe < ApplicationRecord
  belongs_to :event
  belongs_to :character

  scope :approved, -> { where status: 'approved' }
  scope :signed, -> { where status: 'signed' }
  scope :rejected, -> { where status: 'rejected' }
  scope :unknown, -> { where status: 'unknown' }
end
