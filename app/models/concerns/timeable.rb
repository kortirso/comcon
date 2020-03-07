# frozen_string_literal: true

# Represents deliveriable
module Timeable
  extend ActiveSupport::Concern

  included do
    has_one :time_offset, as: :timeable, dependent: :destroy
  end
end
