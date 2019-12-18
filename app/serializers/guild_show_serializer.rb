class GuildShowSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :slug, :locale, :time_offset_value

  def time_offset_value
    object.time_offset&.value
  end
end
