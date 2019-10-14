# Represents available raid roles for characters
class Role < ApplicationRecord
  has_many :character_roles, dependent: :destroy
  has_many :characters, through: :character_roles
end
