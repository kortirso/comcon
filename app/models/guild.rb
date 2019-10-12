# Represents guild
class Guild < ApplicationRecord
  belongs_to :world

  has_many :characters, dependent: :nullify
end
