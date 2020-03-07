# frozen_string_literal: true

class FastCharacterSerializer
  include FastJsonapi::ObjectSerializer

  set_type :character
  attributes :id, :name, :level, :user_id, :slug

  attribute :character_class_name do |object|
    object.character_class.name
  end

  attribute :guild_name do |object|
    object.guild.name unless object.guild_id.nil?
  end

  attribute :roles do |object|
    object.roles.order(main: :desc).pluck(:name)
  end
end
