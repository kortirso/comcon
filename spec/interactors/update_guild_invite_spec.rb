describe UpdateGuildInvite do
  let!(:guild) { create :guild }
  let!(:character) { create :character }
  let!(:guild_invite) { create :guild_invite, guild: guild, character: character }

  describe '.call' do
    context 'for invalid status' do
      let(:interactor) { UpdateGuildInvite.call(guild_invite: guild_invite, status: 10) }

      it 'fails' do
        expect(interactor).to be_a_failure
      end

      it 'and does not update guild invite' do
        interactor
        guild_invite.reload

        expect(guild_invite.status_send?).to eq true
      end
    end

    context 'for valid status' do
      let(:interactor) { UpdateGuildInvite.call(guild_invite: guild_invite, status: 1) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and updates guild invite' do
        interactor
        guild_invite.reload

        expect(guild_invite.status_declined?).to eq true
      end
    end
  end
end
