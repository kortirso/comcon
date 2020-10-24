# frozen_string_literal: true

class GuildBaseSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :locale
end
