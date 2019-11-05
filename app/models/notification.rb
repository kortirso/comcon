# Represents notifications about events
class Notification < ApplicationRecord
  has_many :deliveries, dependent: :destroy
  has_many :guilds, through: :deliveries
end
