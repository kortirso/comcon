# Represents time offsets for users/guilds
class TimeOffset < ApplicationRecord
  belongs_to :timeable, polymorphic: true
end
