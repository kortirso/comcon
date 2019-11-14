RSpec.describe BaseNotificator, type: :service do
  let!(:guild) { create :guild }
  let!(:guild_event) { create :event, eventable: guild }
  let!(:notification) { create :notification, event: 'guild_event_creation' }
  let!(:delivery1) { create :delivery, deliveriable: guild, notification: notification, delivery_type: 0 }
  let!(:delivery2) { create :delivery, deliveriable: guild, notification: notification, delivery_type: 2 }
  let!(:delivery_param) { create :delivery_param, delivery: delivery1 }
  let(:service) { described_class.new(event_name: 'guild_event_creation') }

  describe '.initialize' do
    it 'defines notification variable' do
      expect(service.notification).to eq notification
    end
  end

  describe '.perform_delivery' do
    context 'for discord_webhook delivery_type' do
      let(:request) { service.send(:perform_delivery, delivery: delivery1, event: guild_event) }

      it 'calls DiscordMethod::ExecuteWebhook' do
        expect(DiscordMethod::ExecuteWebhook).to receive(:call)

        request
      end
    end

    context 'for discord_message delivery_type' do
      let(:request) { service.send(:perform_delivery, delivery: delivery2, event: guild_event) }

      it 'calls DiscordMethod::CreateChannelMessage' do
        expect(DiscordMethod::CreateChannelMessage).to receive(:call)

        request
      end
    end
  end

  describe '.render_start_time' do
    let(:request) { service.send(:render_start_time, event: guild_event) }

    it 'returns string' do
      expect(request.is_a?(String)).to eq true
    end
  end
end
