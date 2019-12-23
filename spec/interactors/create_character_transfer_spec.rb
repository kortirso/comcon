describe CreateCharacterTransfer do
  describe '.call' do
    context 'for unexisted character' do
      let(:interactor) { described_class.call(character_id: 'unexisted') }

      it 'fails' do
        expect(interactor).to be_a_failure
      end

      it 'and does not create character transfer' do
        expect { interactor }.to_not change(CharacterTransfer, :count)
      end
    end

    context 'for existed character' do
      let!(:character) { create :character }
      let(:interactor) { described_class.call(character_id: character.id) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and creates character transfer' do
        expect { interactor }.to change { CharacterTransfer.count }.by(1)
      end
    end
  end
end
