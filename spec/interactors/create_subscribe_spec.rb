describe CreateSubscribe do
  let!(:character) { create :character }
  let!(:event) { create :event, owner: character }

  describe '.call' do
    context 'creates subscribe' do
      let(:interactor) { CreateSubscribe.call(event: event, character: character, status: 'signed') }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and creates subscribe' do
        expect { interactor }.to change { Subscribe.count }.by(1)
      end
    end
  end
end
