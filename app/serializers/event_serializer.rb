class EventSerializer < ActiveModel::Serializer
  attributes :id, :name, :date, :time, :slug, :fraction_id, :description, :dungeon_id, :owner_id

  def date
    object.start_time.strftime('%-d.%-m.%Y')
  end

  def time
    {
      hours: object.start_time.strftime('%H').to_i,
      minutes: object.start_time.strftime('%M').to_i
    }
  end
end
