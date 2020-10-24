# frozen_string_literal: true

RSpec.describe Notifies::CreateBankRequest, type: :service do
  let!(:character) { create :character }
  let!(:guild) { create :guild, world: character.world, fraction: character.race.fraction, world_fraction: character.world_fraction }
  let!(:gm) { create :character, guild: guild, world: character.world, race: character.race }
  let!(:guild_role) { create :guild_role, character: gm, guild: guild, name: 'gm' }
  let!(:bank) { create :bank, guild: guild }
  let!(:bank_request) { create :bank_request, bank: bank }
  let!(:notification) { create :notification, event: 'bank_request_creation', status: 1 }
  let!(:delivery) { create :delivery, deliveriable: gm.user, notification: notification }
  let!(:delivery_param) { create :delivery_param, delivery: delivery }
  let!(:identity) { create :identity, user: gm.user }

  describe '.call' do
    it 'calls perform delivery' do
      expect(PerformDelivery).to receive(:call).and_call_original

      described_class.new.call(bank_request: bank_request)
    end
  end
end
