class CharacterIndexSerializer < ActiveModel::Serializer
  attributes :id, :name, :fraction_name, :world_id, :fraction_id

  def fraction_name
    object.race.fraction.name['en']
  end

  def fraction_id
    object.race.fraction_id
  end
end
