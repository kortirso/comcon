# frozen_string_literal: true

# Represents event subscribes
class Subscribe < ApplicationRecord
  enum status: { rejected: 0, unknown: 1, signed: 2, approved: 3, reserve: 4, declined: 5, created: 6 }
  enum for_role: { Tank: 0, Healer: 1, Dd: 2 }

  belongs_to :character
  belongs_to :subscribeable, polymorphic: true
  belongs_to :event, -> { where(subscribes: { subscribeable_type: 'Event' }) }, foreign_key: 'subscribeable_id', optional: true

  scope :status_order, -> { order status: :desc }

  def self.cache_key(subcribes)
    {
      serializer: 'subcribes',
      stat_record: subcribes.maximum(:updated_at)
    }
  end
end
