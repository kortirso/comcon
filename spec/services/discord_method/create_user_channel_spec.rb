RSpec.describe DiscordMethod::CreateUserChannel, type: :service do
  describe '.call' do
    let!(:identity) { create :identity }
    let(:request) { described_class.call(recipient_id: identity.uid) }

    it 'calls DiscordBot::Client with create_user_channel' do
      expect_any_instance_of(DiscordBot::Client).to receive(:create_user_channel)

      request
    end
  end
end
