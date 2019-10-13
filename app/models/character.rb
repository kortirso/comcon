# Represent game characters
class Character < ApplicationRecord
  belongs_to :user
  belongs_to :race
  belongs_to :character_class
  belongs_to :world
  belongs_to :guild, optional: true

  has_many :dungeon_accesses, dependent: :destroy
  has_many :dungeons, through: :dungeon_accesses
  has_many :events, foreign_key: 'owner_id'
end
