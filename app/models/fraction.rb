# Represents game fractions
class Fraction < ApplicationRecord
  has_many :races, dependent: :destroy
  has_many :guilds, dependent: :destroy
end
