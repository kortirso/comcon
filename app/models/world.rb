# Represents game worlds
class World < ApplicationRecord
  has_many :characters, dependent: :destroy

  def full_name
    "#{name} (#{zone})"
  end
end
