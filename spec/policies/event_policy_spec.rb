describe EventPolicy do
  let!(:user) { create :user }
  let!(:character1) { create :character, user: user }
  let!(:character2) { create :character, :orc, world: character1.world }
  let!(:character3) { create :character, world: character1.world, race: character1.race, user: user }
  let!(:world_event1) { create :event, fraction: character1.race.fraction }
  let!(:world_event2) { create :event, fraction: character2.race.fraction }
  let!(:guild) { create :guild, world: character1.world, fraction: character1.race.fraction }
  let!(:guild_event) { create :event, eventable: guild, fraction: character1.race.fraction, owner: character1 }
  before { character3.update(guild: guild) }

  describe '#show?' do
    let(:policy) { described_class.new(world_event1, user: user) }

    context 'if user subscribed' do
      let!(:subscribe) { create :subscribe, subscribeable: world_event1, character: character1 }

      it 'returns true' do
        expect(policy_access).to eq true
      end
    end

    context 'if user is not subscribed' do
      it 'returns false' do
        expect(policy_access).to eq false
      end
    end

    def policy_access
      policy.show?
    end
  end

  describe '#edit?' do
    context 'for not user event' do
      let(:policy) { described_class.new(world_event1, user: user) }

      it 'returns false' do
        expect(policy_access).to eq false
      end
    end

    context 'for user event' do
      let(:policy) { described_class.new(guild_event, user: user) }

      it 'returns true' do
        expect(policy_access).to eq true
      end
    end

    def policy_access
      policy.edit?
    end
  end
end
