RSpec.describe PerformDelivery, type: :service do
  let!(:guild) { create :guild }
  let!(:guild_event) { create :event, eventable: guild }
  let!(:notification) { create :notification, event: 'guild_event_creation', status: 0 }
  let!(:delivery1) { create :delivery, deliveriable: guild, notification: notification, delivery_type: 0 }
  let!(:delivery2) { create :delivery, deliveriable: guild, notification: notification, delivery_type: 2 }
  let!(:delivery_param) { create :delivery_param, delivery: delivery1 }

  describe '.call' do
    context 'for discord_webhook delivery_type' do
      let(:request) { described_class.call(delivery: delivery1, content: notification.content(event_object: guild_event)) }

      it 'calls DiscordMethod::ExecuteWebhook' do
        expect(DiscordMethod::ExecuteWebhook).to receive(:call)

        request
      end
    end

    context 'for discord_message delivery_type' do
      let(:request) { described_class.call(delivery: delivery2, content: notification.content(event_object: guild_event)) }

      it 'calls DiscordMethod::CreateChannelMessage' do
        expect(DiscordMethod::CreateChannelMessage).to receive(:call)

        request
      end
    end
  end
end
