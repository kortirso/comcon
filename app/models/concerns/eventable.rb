# frozen_string_literal: true

# Represents eventable
module Eventable
  extend ActiveSupport::Concern

  included do
    has_many :events, as: :eventable, dependent: :destroy
  end
end
