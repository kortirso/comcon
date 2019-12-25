# Represents news from guilds
class Activity < ApplicationRecord
  belongs_to :guild
end
