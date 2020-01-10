# Represents news
class Activity < ApplicationRecord
  belongs_to :guild, optional: true

  scope :common, -> { where guild_id: nil }

  def from_guild?
    guild_id.present?
  end
end
