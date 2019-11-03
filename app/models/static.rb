require 'babosa'

# Represents guild statics
class Static < ApplicationRecord
  extend FriendlyId

  belongs_to :staticable, polymorphic: true
  belongs_to :fraction
  belongs_to :world

  has_many :static_members, dependent: :destroy
  has_many :characters, through: :static_members

  friendly_id :slug_candidates, use: :slugged

  def normalize_friendly_id(text)
    text.to_slug.transliterate(:russian).normalize.to_s
  end

  private

  def slug_candidates
    [
      :name,
      %i[name staticable_id],
      %i[name staticable_id staticable_type],
      %i[name staticable_id staticable_type id]
    ]
  end
end
