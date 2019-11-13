# Represents notifications about events
class Notification < ApplicationRecord
  enum status: { guild: 0, user: 1 }, _prefix: :status

  has_many :deliveries, dependent: :destroy

  def self.cache_key(notifications)
    {
      serializer: 'notifications',
      stat_record: notifications.maximum(:updated_at)
    }
  end
end
