# frozen_string_literal: true

class NotificationSerializer < ActiveModel::Serializer
  attributes :id, :name, :event, :status
end
