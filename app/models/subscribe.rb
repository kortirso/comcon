# Represents event subscribes
class Subscribe < ApplicationRecord
  enum status: { rejected: 0, unknown: 1, signed: 2, approved: 3, reserve: 4 }
  enum for_role: { Tank: 0, Healer: 1, Dd: 2 }

  belongs_to :character
  belongs_to :subscribeable, polymorphic: true
  belongs_to :event, -> { where(subscribes: { subscribeable_type: 'Event' }) }, foreign_key: 'subscribeable_id', optional: true

  scope :status_order, -> { order status: :desc }
end
