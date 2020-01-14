# Send notifications for users about close event
every 10.minutes do
  runner 'NotifyComingSoonEventsJob.perform_later'
end

# Check all items
every 1.minute do
  runner 'GetGameItemsJob.perform_later'
end
