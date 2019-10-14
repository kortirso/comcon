# Represents event subscribes
class Subscribe < ApplicationRecord
  belongs_to :event
  belongs_to :character

  scope :approved, -> { where approved: true }
  scope :declined, -> { where approved: false }
end
