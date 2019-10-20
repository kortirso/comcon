# Represents combinateable
module Combinateable
  extend ActiveSupport::Concern

  included do
    has_many :combinations, as: :combinateable, dependent: :destroy
  end
end
