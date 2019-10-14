# Represents event subscribes
class Subscribe < ApplicationRecord
  belongs_to :event
  belongs_to :character

  scope :approved, -> { where signed: true, approved: true }
  scope :signed, -> { where signed: true, approved: false }
  scope :rejected, -> { where signed: false, approved: false }
end
