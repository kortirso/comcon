# Represents available raid roles for characters
class Role < ApplicationRecord
  include Combinateable

  has_many :character_roles, dependent: :destroy
  has_many :characters, through: :character_roles
end
