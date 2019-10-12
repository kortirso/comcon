# Represents game worlds
class World < ApplicationRecord
  def full_name
    "#{name} (#{zone})"
  end
end
