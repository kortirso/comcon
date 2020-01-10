# Send notifications for users about close event
every 10.minutes do
  runner 'NotifyComingSoonEventsJob.perform_now'
end

# Check all items
every 1.minutes do
  runner 'GetGameItemsJob.perform_now'
end
