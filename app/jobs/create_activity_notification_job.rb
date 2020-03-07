# frozen_string_literal: true

# Send notifications about creating events
class CreateActivityNotificationJob < ApplicationJob
  queue_as :default

  def perform(activity_id:)
    activity = Activity.find_by(id: activity_id)
    return if activity.nil?
    Notifies::CreateActivity.new.call(activity: activity)
  end
end
