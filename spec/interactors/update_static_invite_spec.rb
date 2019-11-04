describe UpdateStaticInvite do
  let!(:guild) { create :guild }
  let!(:character) { create :character, guild: guild }
  let!(:static) { create :static, staticable: guild, world: character.world, fraction: character.race.fraction }
  let!(:static_invite) { create :static_invite, static: static, character: character }

  describe '.call' do
    context 'for invalid status' do
      let(:interactor) { UpdateStaticInvite.call(static_invite: static_invite, status: 10) }

      it 'fails' do
        expect(interactor).to be_a_failure
      end

      it 'and does not update static invite' do
        interactor
        static_invite.reload

        expect(static_invite.status_send?).to eq true
      end
    end

    context 'for valid status' do
      let(:interactor) { UpdateStaticInvite.call(static_invite: static_invite, status: 2) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and updates static invite' do
        interactor
        static_invite.reload

        expect(static_invite.status_approved?).to eq true
      end
    end
  end
end
