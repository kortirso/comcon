RSpec.describe CreateEventNotificationJob, type: :job do
  let!(:event) { create :event }

  it 'executes Notificators::CreateEventNotificator.call' do
    expect(Notificators::CreateEventNotificator).to receive(:call).and_call_original

    described_class.perform_now(event_id: event.id)
  end
end
