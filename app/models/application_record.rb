# base model
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def normalize_friendly_id(text)
    text.to_slug.transliterate(:russian).normalize.to_s
  end
end
