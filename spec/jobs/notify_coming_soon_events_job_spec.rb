RSpec.describe NotifyComingSoonEventsJob, type: :job do
  it 'executes Notificators::Users::ComingSoonEventsNotificator.call' do
    expect(Notificators::Users::ComingSoonEventsNotificator).to receive(:call).and_call_original

    described_class.perform_now
  end
end
