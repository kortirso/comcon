# Represents races
class Race < ApplicationRecord
  belongs_to :fraction

  has_many :characters, dependent: :destroy
end
