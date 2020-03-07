# frozen_string_literal: true

class FastCharacterSerializer
  include FastJsonapi::ObjectSerializer

  set_type :character
  attributes :id, :name, :level, :user_id, :slug, :item_level

  attribute :character_class_name do |object|
    object.character_class.name
  end

  attribute :guild_name do |object|
    object.guild.name unless object.guild_id.nil?
  end

  attribute :roles, &:current_roles
end
