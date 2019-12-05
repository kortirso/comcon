RSpec.describe Notifies::CreateGuildRequest, type: :service do
  let!(:character) { create :character }
  let!(:guild) { create :guild, world: character.world, fraction: character.race.fraction, world_fraction: character.world_fraction }
  let!(:gm) { create :character, guild: guild, world: character.world, race: character.race }
  let!(:guild_role) { create :guild_role, character: gm, guild: guild, name: 'gm' }
  let!(:guild_invite) { create :guild_invite, character: character, guild: guild }
  let!(:notification) { create :notification, event: 'guild_request_creation', status: 1 }
  let!(:delivery) { create :delivery, deliveriable: gm.user, notification: notification }
  let!(:delivery_param) { create :delivery_param, delivery: delivery }
  let!(:identity) { create :identity, user: gm.user }

  describe '.call' do
    it 'calls perform delivery' do
      expect(PerformDelivery).to receive(:call).and_call_original

      described_class.new.call(guild_invite: guild_invite)
    end
  end
end
