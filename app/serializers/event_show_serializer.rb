# frozen_string_literal: true

class EventShowSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :date, :time, :fraction_name, :dungeon_name, :owner_name, :eventable_type, :eventable_name, :group_role

  def date
    object.start_time.strftime('%-d.%-m.%Y')
  end

  def time
    {
      hours:   object.start_time.strftime('%H').to_i,
      minutes: object.start_time.strftime('%M').to_i
    }
  end

  def fraction_name
    object.fraction.name
  end

  def dungeon_name
    object.dungeon&.name
  end

  def owner_name
    object.owner.full_name
  end

  def eventable_name
    return object.eventable.full_name if object.eventable_type == 'Guild'

    object.eventable.name
  end

  def group_role
    return nil if object.group_role.nil?
    return nil unless object.group_role.defined?

    object.group_role.value
  end
end
