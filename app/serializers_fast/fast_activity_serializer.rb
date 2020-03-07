# frozen_string_literal: true

class FastActivitySerializer
  include FastJsonapi::ObjectSerializer

  set_type :activity
  attributes :title, :description

  attribute :guild_name do |object|
    object.guild.full_name if object.from_guild?
  end

  attribute :created_at do |object|
    object.created_at.to_i
  end

  attribute :updated_at do |object|
    object.updated_at.to_i
  end
end
