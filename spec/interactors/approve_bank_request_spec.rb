describe ApproveBankRequest do
  let!(:bank) { create :bank }
  let!(:game_item) { create :game_item }
  let!(:bank_request) { create :bank_request, bank: bank, game_item: game_item, requested_amount: 1 }

  describe '.call' do
    context 'for unexisted bank cell' do
      let(:interactor) { described_class.call(bank_request: bank_request, provided_amount: 1) }

      it 'fails' do
        expect(interactor).to be_a_failure
      end

      it 'and does not update bank request' do
        interactor
        bank_request.reload

        expect(bank_request.status).to eq 'send'
      end
    end

    context 'for existed bank cell' do
      let!(:bank_cell) { create :bank_cell, bank: bank, game_item: game_item, amount: 10 }

      context 'for too many items' do
        let(:interactor) { described_class.call(bank_request: bank_request, provided_amount: 20) }

        it 'fails' do
          expect(interactor).to be_a_failure
        end

        it 'and does not update bank request' do
          interactor
          bank_request.reload

          expect(bank_request.status).to eq 'send'
        end
      end

      context 'for valid params' do
        let(:interactor) { described_class.call(bank_request: bank_request, provided_amount: 1) }

        it 'succeeds' do
          expect(interactor).to be_a_success
        end

        it 'and updates bank request' do
          interactor
          bank_request.reload

          expect(bank_request.status).to eq 'completed'
        end

        it 'and updates bank cell' do
          interactor
          bank_cell.reload

          expect(bank_cell.amount).to eq 9
        end
      end
    end
  end
end
