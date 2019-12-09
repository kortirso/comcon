describe RemoveGuildRole do
  let!(:guild) { create :guild }
  let!(:character) { create :character }

  describe '.call' do
    context 'without guild role' do
      let(:interactor) { described_class.call(guild: guild, character: character) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and does not delete guild roles' do
        expect { interactor }.to_not change(GuildRole, :count)
      end

      it 'and updates character' do
        interactor
        character.reload

        expect(character.guild_id).to eq nil
      end
    end

    context 'without guild role' do
      let!(:guild_role) { create :guild_role, guild: guild, character: character, name: 'gm' }
      let(:interactor) { described_class.call(guild: guild, character: character) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and deletes guild roles' do
        expect { interactor }.to change { GuildRole.count }.by(-1)
      end

      it 'and updates character' do
        interactor
        character.reload

        expect(character.guild_id).to eq nil
      end
    end
  end
end
