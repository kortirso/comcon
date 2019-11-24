class StaticSerializer < ActiveModel::Serializer
  attributes :id, :name, :staticable_id, :staticable_type, :description, :guild_slug, :privy, :fraction_name, :fraction_id, :world_id, :owner_name, :slug

  def guild_slug
    return nil if object.staticable_type == 'Character'
    object.staticable.slug
  end

  def fraction_name
    object.fraction.name
  end

  def owner_name
    object.staticable.full_name
  end
end
