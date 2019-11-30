RSpec.describe CreateEventNotificationJob, type: :job do
  context 'for guild event' do
    let!(:guild) { create :guild }
    let!(:event) { create :event, eventable: guild }

    it 'executes Notificators::CreateEventNotificator.call' do
      expect(Notificators::CreateEventNotificator).to receive(:call).and_call_original

      described_class.perform_now(event_id: event.id)
    end
  end

  context 'for guild static event' do
    let!(:guild) { create :guild }
    let!(:static) { create :static, staticable: guild }
    let!(:event) { create :event, eventable: static }

    it 'executes Notificators::CreateEventNotificator.call' do
      expect(Notificators::CreateEventForGuildStaticNotificator).to receive(:call).and_call_original

      described_class.perform_now(event_id: event.id)
    end
  end
end
