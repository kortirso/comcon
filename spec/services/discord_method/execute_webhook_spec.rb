# frozen_string_literal: true

RSpec.describe DiscordMethod::ExecuteWebhook, type: :service do
  describe '.call' do
    let!(:delivery_param) { create :delivery_param, params: { 'id' => '123', 'token' => '321' } }
    let(:request) { described_class.call(delivery_param: delivery_param, content: '123') }

    it 'calls DiscordBot::Client with execute_webhook' do
      expect_any_instance_of(DiscordBot::Client).to receive(:execute_webhook)

      request
    end
  end
end
