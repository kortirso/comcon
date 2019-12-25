RSpec.describe Notifies::CreateActivity, type: :service do
  let!(:character) { create :character }
  let!(:guild) { create :guild, world: character.world, fraction: character.race.fraction, world_fraction: character.world_fraction }
  let!(:time_offset) { create :time_offset, timeable: guild }
  let!(:activity) { create :activity, guild: guild }
  let!(:guild_notification) { create :notification, event: 'activity_creation', status: 0 }
  let!(:user_notification) { create :notification, event: 'activity_creation', status: 1 }
  let!(:delivery1) { create :delivery, deliveriable: guild, notification: guild_notification }
  let!(:delivery_param) { create :delivery_param, delivery: delivery1 }
  let!(:delivery2) { create :delivery, deliveriable: character.user, notification: user_notification }
  let!(:delivery_param) { create :delivery_param, delivery: delivery2 }
  let!(:identity) { create :identity, user: character.user }
  let(:service) { described_class.new }

  describe '.call' do
    it 'calls perform delivery' do
      expect(PerformDelivery).to receive(:call).and_call_original

      service.call(activity: activity)
    end
  end

  describe '.notify_guild' do
    it 'calls perform delivery' do
      expect(PerformDelivery).to receive(:call).and_call_original

      service.send(:notify_guild, guild_id: guild.id, event_name: 'activity_creation', activity: activity)
    end
  end

  describe '.notify_users' do
    before { character.update(guild: guild) }

    it 'calls perform delivery' do
      expect(PerformDelivery).to receive(:call).and_call_original

      service.send(:notify_users, object: guild, event_name: 'activity_creation', activity: activity)
    end
  end
end
