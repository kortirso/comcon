describe CreateGuildInvite do
  let!(:guild) { create :guild }
  let!(:character) { create :character }
  let!(:other_character) { create :character, guild: guild }

  describe '.call' do
    context 'for existed guild invite' do
      let!(:guild_invite) { create :guild_invite, guild: guild, character: character, from_guild: true }
      let(:interactor) { CreateGuildInvite.call(guild: guild, character: character, from_guild: true) }

      it 'fails' do
        expect(interactor).to be_a_failure
      end

      it 'and does not create guild invite' do
        expect { interactor }.to_not change(guild.guild_invites, :count)
      end
    end

    context 'for other character' do
      let(:interactor) { CreateGuildInvite.call(guild: guild, character: other_character, from_guild: true) }

      it 'fails' do
        expect(interactor).to be_a_failure
      end

      it 'and does not create guild invite' do
        expect { interactor }.to_not change(guild.guild_invites, :count)
      end
    end

    context 'for unexisted guild invite' do
      let(:interactor) { CreateGuildInvite.call(guild: guild, character: character, from_guild: true) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and creates guild invite' do
        expect { interactor }.to change { guild.guild_invites.count }.by(1)
      end
    end
  end
end
