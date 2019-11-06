# Represents notifications about events
class Notification < ApplicationRecord
  has_many :deliveries, dependent: :destroy

  def self.cache_key(notifications)
    {
      serializer: 'notifications',
      stat_record: notifications.maximum(:updated_at)
    }
  end
end
