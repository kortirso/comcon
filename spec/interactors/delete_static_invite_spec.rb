describe DeleteStaticInvite do
  let!(:guild) { create :guild }
  let!(:character) { create :character, guild: guild }
  let!(:static) { create :static, staticable: guild, world: character.world, fraction: character.race.fraction }
  let!(:static_invite) { create :static_invite, static: static, character: character }

  describe '.call' do
    let(:interactor) { described_class.call(static_invite: static_invite) }

    it 'succeeds' do
      expect(interactor).to be_a_success
    end

    it 'and deletes static invite' do
      expect { interactor }.to change { StaticInvite.count }.by(-1)
    end
  end
end
