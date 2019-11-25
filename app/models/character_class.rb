# Represents character classes
class CharacterClass < ApplicationRecord
  has_many :characters, dependent: :destroy
  has_many :combinations, dependent: :destroy
  has_many :combinateables, through: :combinations, source_type: 'Role'
  has_many :role_combinations, -> { where combinateable_type: 'Role' }, class_name: 'Combination'
  has_many :available_roles, through: :role_combinations, source: :combinateable, source_type: 'Role'

  def to_hash
    {
      id.to_s => {
        'name' => name,
        'roles' => combinateables.inject({}) do |roles, role|
          roles.merge(role.to_hash)
        end
      }
    }
  end
end
