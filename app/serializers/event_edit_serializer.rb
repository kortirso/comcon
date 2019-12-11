class EventEditSerializer < ActiveModel::Serializer
  attributes :id, :name, :date, :time, :slug, :fraction_id, :description, :dungeon_id, :owner_id, :event_type, :eventable_type, :eventable_id, :group_role, :fraction_name, :hours_before_close

  def date
    object.start_time.strftime('%-d.%-m.%Y')
  end

  def time
    {
      hours: object.start_time.strftime('%H').to_i,
      minutes: object.start_time.strftime('%M').to_i
    }
  end

  def fraction_name
    object.fraction.name
  end

  def group_role
    return nil if object.group_role.nil?
    return nil unless object.group_role.defined?
    object.group_role.value
  end
end
