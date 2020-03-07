# frozen_string_literal: true

class FastCharacterIndexSerializer
  include FastJsonapi::ObjectSerializer

  set_type :character
  attributes :id, :name, :level

  attribute :race_name do |object|
    object.race.name
  end

  attribute :character_class_name do |object|
    object.character_class.name
  end

  attribute :world_name do |object|
    object.world.full_name
  end

  attribute :guild_name do |object|
    object.guild.name unless object.guild_id.nil?
  end

  attribute :fraction_name do |object|
    object.race.fraction.name unless object.guild_id.nil?
  end

  attribute :created_at do |object|
    object.created_at.to_i
  end

  attribute :updated_at do |object|
    object.updated_at.to_i
  end
end
