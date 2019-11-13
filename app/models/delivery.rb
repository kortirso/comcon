# Represents deliveries for guilds
class Delivery < ApplicationRecord
  enum delivery_type: {
    discord_webhook: 0,
    email: 1,
    discord_message: 2
  }

  belongs_to :deliveriable, polymorphic: true
  belongs_to :notification

  has_one :delivery_param, dependent: :destroy
end
