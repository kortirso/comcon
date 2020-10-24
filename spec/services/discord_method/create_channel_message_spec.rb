# frozen_string_literal: true

RSpec.describe DiscordMethod::CreateChannelMessage, type: :service do
  describe '.call' do
    let!(:delivery_param) { create :delivery_param, params: { 'channel_id' => '123' } }
    let(:request) { described_class.call(delivery_param: delivery_param, content: '123') }

    it 'calls DiscordBot::Client with create_channel_message' do
      expect_any_instance_of(DiscordBot::Client).to receive(:create_channel_message)

      request
    end
  end
end
