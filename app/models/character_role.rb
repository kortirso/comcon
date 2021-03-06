# frozen_string_literal: true

# Represent character roles
class CharacterRole < ApplicationRecord
  belongs_to :character
  belongs_to :role
end
