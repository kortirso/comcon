# Represents events
class Event < ApplicationRecord
  extend FriendlyId

  friendly_id :slug, use: :slugged

  belongs_to :owner, class_name: 'Character'

  def normalize_friendly_id(text)
    text.to_slug.transliterate(:russian).normalize.to_s
  end
end
