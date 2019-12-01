RSpec.describe CreateEventNotificationJob, type: :job do
  let!(:guild) { create :guild }
  let!(:event) { create :event, eventable: guild }
  let!(:guild_notification) { create :notification, event: 'guild_event_creation', status: 0 }
  let!(:user_notification) { create :notification, event: 'guild_event_creation', status: 1 }

  it 'executes Notifies::CreateEvent.call' do
    expect_any_instance_of(Notifies::CreateEvent).to receive(:call).and_call_original

    described_class.perform_now(event_id: event.id)
  end
end
