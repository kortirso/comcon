# frozen_string_literal: true

# Represents deliveriable
module Deliveriable
  extend ActiveSupport::Concern

  included do
    has_many :deliveries, as: :deliveriable, dependent: :destroy
    has_many :notifications, -> { distinct }, through: :deliveries
  end
end
