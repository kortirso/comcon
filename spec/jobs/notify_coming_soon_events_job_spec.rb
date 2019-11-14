RSpec.describe NotifyComingSoonEventsJob, type: :job do
  it 'executes Notificators::ComingSoonEventsNotificator.call' do
    expect(Notificators::ComingSoonEventsNotificator).to receive(:call).and_call_original

    described_class.perform_now
  end
end
