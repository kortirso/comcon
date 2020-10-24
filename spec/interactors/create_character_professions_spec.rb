# frozen_string_literal: true

describe CreateCharacterProfessions do
  let!(:character) { create :character, :human_warrior }
  let!(:profession) { create :profession }

  describe '.call' do
    context 'for unexisted character profession' do
      let(:interactor) { described_class.call(character_id: character.id, profession_params: { profession.id.to_s => '1' }) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and creates character profession' do
        expect { interactor }.to change { character.professions.count }.by(1)
      end
    end

    context 'for existed character profession' do
      let!(:character_profession) { create :character_profession, character: character, profession: profession }
      let(:interactor) { described_class.call(character_id: character.id, profession_params: { profession.id.to_s => '0' }) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and deletes character profession' do
        expect { interactor }.to change(CharacterProfession, :count).by(-1)
      end
    end
  end
end
