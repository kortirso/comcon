# Represents game fractions
class Fraction < ApplicationRecord
  has_many :races, dependent: :destroy
end
