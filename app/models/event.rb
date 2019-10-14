# Represents events
class Event < ApplicationRecord
  extend FriendlyId

  friendly_id :name, use: :slugged

  belongs_to :owner, class_name: 'Character'
  belongs_to :dungeon, optional: true
  belongs_to :eventable, polymorphic: true
  belongs_to :fraction

  has_many :subscribes, dependent: :destroy
  has_many :approved_subscribes, -> { where signed: true, approved: true }, class_name: 'Subscribe'
  has_many :signed_subscribes, -> { where signed: true, approved: false }, class_name: 'Subscribe'
  has_many :rejected_subscribes, -> { where signed: false, approved: false }, class_name: 'Subscribe'
  has_many :characters, through: :subscribes
  has_many :approved_characters, through: :approved_subscribes, source: :character
  has_many :signed_characters, through: :signed_subscribes, source: :character
  has_many :rejected_characters, through: :rejected_subscribes, source: :character

  def normalize_friendly_id(text)
    text.to_slug.transliterate(:russian).normalize.to_s
  end
end
