# frozen_string_literal: true

# Represents relationships between character classes and other models
class Combination < ApplicationRecord
  belongs_to :character_class
  belongs_to :combinateable, polymorphic: true
end
