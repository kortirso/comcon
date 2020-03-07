# frozen_string_literal: true

# Represents members of statics
class StaticMember < ApplicationRecord
  belongs_to :static
  belongs_to :character
end
