class StaticSerializer < ActiveModel::Serializer
  attributes :id, :name, :staticable_id, :staticable_type, :description, :guild_slug, :privy

  def guild_slug
    return nil if object.staticable_type == 'Character'
    object.staticable.slug
  end
end
