# frozen_string_literal: true

# Represents delivery params for deliveries
class DeliveryParam < ApplicationRecord
  belongs_to :delivery
end
