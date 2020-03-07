# frozen_string_literal: true

# Represents staticable
module Staticable
  extend ActiveSupport::Concern

  included do
    has_many :statics, as: :staticable, dependent: :destroy
  end
end
