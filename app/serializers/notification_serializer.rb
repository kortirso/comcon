class NotificationSerializer < ActiveModel::Serializer
  attributes :id, :name, :event, :status
end
