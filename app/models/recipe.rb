# Represents recipes for professions
class Recipe < ApplicationRecord
  belongs_to :profession
end
