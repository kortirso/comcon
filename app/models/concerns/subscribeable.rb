# frozen_string_literal: true

# Represents subscribeable
module Subscribeable
  extend ActiveSupport::Concern

  included do
    has_many :subscribes, as: :subscribeable, dependent: :destroy
  end
end
