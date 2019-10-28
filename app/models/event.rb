# Represents events
class Event < ApplicationRecord
  extend FriendlyId

  friendly_id :slug_candidates, use: :slugged

  belongs_to :owner, class_name: 'Character'
  belongs_to :dungeon, optional: true
  belongs_to :eventable, polymorphic: true
  belongs_to :fraction

  has_many :subscribes, dependent: :destroy
  has_many :characters, through: :subscribes

  def self.available_for_user(user)
    user.characters.map do |character|
      available_for_character(character)
    end.flatten.uniq
  end

  def self.available_for_character(character)
    where("eventable_type = 'World' AND eventable_id = ? AND fraction_id = ? OR eventable_type = 'Guild' AND eventable_id = ?", character.world_id, character.race.fraction_id, character.guild_id)
  end

  def is_open?
    DateTime.now < start_time - hours_before_close.hours
  end

  private

  def slug_candidates
    [
      :name,
      %i[name owner_id],
      %i[name owner_id id]
    ]
  end
end
