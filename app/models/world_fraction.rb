# frozen_string_literal: true

# Represents combinations of worlds and fractions
class WorldFraction < ApplicationRecord
  belongs_to :world
  belongs_to :fraction

  has_many :events, dependent: :destroy
  has_many :characters, dependent: :destroy
  has_many :guilds, dependent: :destroy
  has_many :statics, dependent: :destroy
end
