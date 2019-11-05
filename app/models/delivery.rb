# Represents deliveries for guilds
class Delivery < ApplicationRecord
  enum delivery_type: {
    discord_webhook: 0,
    email: 1
  }

  belongs_to :guild
  belongs_to :notification

  has_one :delivery_param, dependent: :destroy
end
