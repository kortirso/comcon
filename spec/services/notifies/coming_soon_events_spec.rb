RSpec.describe Notifies::ComingSoonEvents, type: :service do
  let!(:event) { create :event, start_time: DateTime.now.utc + 35.minutes }
  let!(:notification) { create :notification, event: 'event_start_soon', status: 1 }
  let!(:character) { create :character }
  let!(:delivery) { create :delivery, deliveriable: character.user, notification: notification }
  let!(:delivery_param) { create :delivery_param, delivery: delivery }
  let!(:identity) { create :identity, user: character.user }
  let!(:subscribe) { create :subscribe, subscribeable: event, character: character, status: 2 }

  describe 'self.call' do
    it 'executes call for PerformDelivery' do
      expect(PerformDelivery).to receive(:call).and_call_original

      described_class.new.call
    end
  end
end
