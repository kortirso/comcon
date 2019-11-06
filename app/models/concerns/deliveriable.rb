# Represents deliveriable
module Deliveriable
  extend ActiveSupport::Concern

  included do
    has_many :deliveries, as: :deliveriable, dependent: :destroy
    has_many :notifications, through: :deliveries
  end
end