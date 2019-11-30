RSpec.describe Notificators::Users::ComingSoonEventsNotificator, type: :service do
  let!(:event) { create :event, start_time: DateTime.now.utc + 35.minutes }
  let!(:notification) { create :notification, event: 'event_start_soon' }
  let!(:character) { create :character }
  let!(:subscribe) { create :subscribe, event: event, character: character, status: 2 }
  let(:service) { described_class.new }

  describe 'self.call' do
    it 'executes call for Notificators::Users::ComingSoonEventsNotificator object' do
      expect_any_instance_of(described_class).to receive(:call).and_call_original

      described_class.call
    end
  end

  describe '.initialize' do
    it 'defines deliveriable_type variable' do
      expect(service.deliveriable_type).to eq 'User'
    end

    it 'and defines notification variable' do
      expect(service.notification).to eq notification
    end
  end

  describe '.define_content' do
    let(:response) { service.send(:define_content, event: event) }

    it 'returns string with content' do
      expect(response.is_a?(String)).to eq true
    end
  end
end
