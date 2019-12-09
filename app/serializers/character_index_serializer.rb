class CharacterIndexSerializer < ActiveModel::Serializer
  attributes :id, :name, :fraction_name

  def fraction_name
    object.race.fraction.name['en']
  end
end
