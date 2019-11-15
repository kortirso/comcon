# Represents available raid roles for characters
class Role < ApplicationRecord
  include Combinateable

  ROLE_VALUES = {
    'Tank' => 0,
    'Healer' => 1,
    'Melee' => 2,
    'Ranged' => 3
  }.freeze

  has_many :character_roles, dependent: :destroy
  has_many :characters, through: :character_roles
end
