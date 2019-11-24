describe CreateGuild do
  let!(:user) { create :user }
  let!(:character) { create :character, user: user }
  let!(:guild) { create :guild, world: character.world, fraction: character.race.fraction }

  describe '.call' do
    context 'for invalid guild params' do
      let(:interactor) { described_class.call(guild_params: { name: '', description: '' }, character: character) }

      it 'fails' do
        expect(interactor).to be_a_failure
      end

      it 'and does not create new guild' do
        expect { interactor }.to_not change(Guild, :count)
      end
    end

    context 'for valid params' do
      let(:interactor) { described_class.call(guild_params: { name: '123', description: '2' }, character: character) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and creates new guild' do
        expect { interactor }.to change { Guild.count }.by(1)
      end

      it 'and provides guild' do
        expect(interactor.guild).to eq Guild.last
      end
    end
  end

  describe '.rollback' do
    subject(:interactor) { described_class.new(guild_params: { name: '123', description: '2' }, character: character) }

    it 'removes the created guild' do
      interactor.call

      expect { interactor.rollback }.to change { Guild.count }.by(-1)
    end
  end
end
