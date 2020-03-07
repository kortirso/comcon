# frozen_string_literal: true

# Base notify class
class Notify
  private

  def do_notify(receiver_ids:, receiver_type:, notification_id:, content:)
    Delivery.where(deliveriable_id: receiver_ids, deliveriable_type: receiver_type, notification_id: notification_id).includes(:delivery_param).each do |delivery|
      PerformDelivery.call(delivery: delivery, content: content)
    end
  end
end
