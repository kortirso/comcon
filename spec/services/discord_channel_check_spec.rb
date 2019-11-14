RSpec.describe DiscordChannelCheck, type: :service do
  let!(:user) { create :user }
  let!(:identity) { create :identity, user: user }
  let!(:guild) { create :guild }
  let!(:guild_event) { create :event, eventable: guild }
  let!(:notification) { create :notification, event: 'guild_event_creation' }
  let!(:delivery1) { create :delivery, deliveriable: guild, notification: notification, delivery_type: 0 }
  let!(:delivery2) { create :delivery, deliveriable: user, notification: notification, delivery_type: 2 }
  let!(:delivery_param1) { create :delivery_param, delivery: delivery1 }
  let!(:delivery_param2) { create :delivery_param, delivery: delivery2, params: { 'channel_id' => '' } }
  let!(:delivery_param3) { create :delivery_param, delivery: delivery2, params: { 'channel_id' => 'some_id' } }
  let(:service1) { described_class.new(delivery_param: delivery_param2) }
  let(:service2) { described_class.new(delivery_param: delivery_param3) }

  describe 'self.call' do
    it 'executes call for DiscordChannelCheck object' do
      expect_any_instance_of(described_class).to receive(:call).and_call_original

      described_class.call(delivery_param: delivery_param2)
    end
  end

  describe '.initialize' do
    it 'defines delivery_param variable' do
      expect(service1.delivery_param).to eq delivery_param2
    end
  end

  describe '.call' do
    context 'for User deliveriable type' do
      it 'calls DiscordMethod::GetChannel for checking channel' do
        expect(DiscordMethod::GetChannel).to receive(:call).and_call_original

        service2.call
      end

      it 'calls DiscordMethod::CreateUserChannel for creating channel' do
        expect(DiscordMethod::CreateUserChannel).to receive(:call).and_call_original

        service1.call
      end
    end
  end
end
