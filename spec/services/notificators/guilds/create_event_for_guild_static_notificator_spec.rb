RSpec.describe Notificators::Guilds::CreateEventForGuildStaticNotificator, type: :service do
  let!(:guild) { create :guild }
  let!(:static) { create :static, staticable: guild }
  let!(:guild_event) { create :event, eventable: static }
  let!(:notification) { create :notification, event: 'event_creation_for_guild_static' }
  let!(:delivery) { create :delivery, deliveriable: guild, notification: notification }
  let!(:delivery_param) { create :delivery_param, delivery: delivery }
  let(:service) { described_class.new }

  describe 'self.call' do
    it 'executes call for Notificators::Guilds::CreateEventForGuildStaticNotificator object' do
      expect_any_instance_of(described_class).to receive(:call).and_call_original

      described_class.call(event_id: guild_event.id)
    end
  end

  describe '.initialize' do
    it 'defines deliveriable_type variable' do
      expect(service.deliveriable_type).to eq 'Guild'
    end

    it 'and defines notification variable' do
      expect(service.notification).to eq notification
    end
  end

  describe '.call' do
    context 'for unexisted event' do
      let(:response) { service.call(event_id: 'unexisted') }

      it 'returns nil' do
        expect(response).to eq nil
      end
    end
  end

  describe '.define_content' do
    let(:response) { service.send(:define_content, event: guild_event) }

    it 'returns string with content' do
      expect(response.is_a?(String)).to eq true
    end
  end
end
