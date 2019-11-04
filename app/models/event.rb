require 'babosa'

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

  scope :for_statics, -> { where eventable_type: 'Static' }

  def self.available_for_user(user)
    user.characters.map do |character|
      available_for_character(character)
    end.flatten.uniq
  end

  def self.available_for_character(character)
    static_ids = character.in_statics.pluck(:id)
    where("eventable_type = 'World' AND eventable_id = ? AND fraction_id = ? OR eventable_type = 'Guild' AND eventable_id = ?", character.world_id, character.race.fraction_id, character.guild_id).or(for_statics.where(eventable_id: static_ids))
  end

  def normalize_friendly_id(text)
    text.to_slug.transliterate(:russian).normalize.to_s
  end

  def is_open?
    DateTime.now < start_time - hours_before_close.hours
  end

  def guild_role_of_user(user_id)
    return nil if eventable_type != 'Guild'
    # leaders from guild of this user
    leaders = eventable.characters_with_leader_role.select { |character| character.user_id == user_id }
    return nil if leaders.empty?
    return ['rl', nil] if leaders.any? { |character| character.guild_role.name == 'rl' }
    class_leading = leaders.select { |character| character.guild_role.name == 'cl' }
    return nil if class_leading.empty?
    ['cl', class_leading.map! { |character| character.character_class.name['en'] }]
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
