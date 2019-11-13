# Rebuilding Indices
every 10.minutes do
  rake 'ts:rebuild'
end

# Send notifications for users about close event
every 10.minutes do
  runner 'NotifyComingSoonEventsJob.perform_now'
end
