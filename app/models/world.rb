# Represents game worlds
class World < ApplicationRecord
  has_many :characters, dependent: :destroy
  has_many :guilds, dependent: :destroy

  def full_name
    "#{name} (#{zone})"
  end
end
