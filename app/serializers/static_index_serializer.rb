class StaticIndexSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :privy, :staticable_id, :staticable_type, :fraction_name, :fraction_id, :world_id, :slug

  def fraction_name
    object.fraction.name
  end
end
