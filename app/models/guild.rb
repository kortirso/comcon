# Represents guild
class Guild < ApplicationRecord
  belongs_to :world
  belongs_to :fraction

  has_many :characters, dependent: :nullify

  def full_name(locale = 'en')
    "#{name}, #{fraction.name[locale]}, #{world.full_name}"
  end
end
