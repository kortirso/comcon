class StaticSerializer < ActiveModel::Serializer
  attributes :id, :name, :staticable_id, :staticable_type, :description, :guild_slug, :privy, :fraction_name, :fraction_id, :world_id, :owner_name, :slug, :group_role

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

  def group_role
    return nil if object.group_role.nil?
    return nil unless object.group_role.defined?
    object.group_role.value
  end
end
