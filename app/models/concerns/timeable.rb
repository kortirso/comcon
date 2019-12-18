# Represents deliveriable
module Timeable
  extend ActiveSupport::Concern

  included do
    has_one :time_offset, as: :timeable, dependent: :destroy
  end
end
