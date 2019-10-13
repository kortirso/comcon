describe CreateDungeonAccess do
  let!(:character) { create :character, :human_warrior }
  let!(:dungeon) { create :dungeon }

  describe '.call' do
    context 'for unexisted access' do
      let(:interactor) { CreateDungeonAccess.call(character_id: character.id, dungeon_params: { dungeon.id.to_s => '1' }) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and creates access' do
        expect { interactor }.to change { character.dungeon_accesses.count }.by(1)
      end
    end

    context 'for existed access' do
      let!(:dungeon_access) { create :dungeon_access, character: character, dungeon: dungeon }
      let(:interactor) { CreateDungeonAccess.call(character_id: character.id, dungeon_params: { dungeon.id.to_s => '0' }) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and deletes access' do
        expect { interactor }.to change { DungeonAccess.count }.by(-1)
      end
    end
  end
end
