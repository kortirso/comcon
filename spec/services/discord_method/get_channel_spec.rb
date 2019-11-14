RSpec.describe DiscordMethod::GetChannel, type: :service do
  describe '.call' do
    let!(:delivery_param) { create :delivery_param, params: { 'channel_id' => '123' } }
    let(:request) { described_class.call(channel_id: delivery_param.params['channel_id']) }

    it 'calls DiscordBot::Client with get_channel' do
      expect_any_instance_of(DiscordBot::Client).to receive(:get_channel)

      request
    end
  end
end
