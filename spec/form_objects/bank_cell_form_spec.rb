RSpec.describe BankCellForm, type: :service do
  let!(:bank) { create :bank }

  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { described_class.new(bank: nil) }

      it 'does not create new bank cell' do
        expect { service.persist? }.to_not change(BankCell, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let(:service) { described_class.new(item_uid: 11_370, amount: 10, bank: bank) }

      it 'creates new bank cell' do
        expect { service.persist? }.to change { bank.bank_cells.count }.by(1)
      end

      it 'and returns true' do
        expect(service.persist?).to eq true
      end
    end

    context 'for updating' do
      let!(:bank_cell) { create :bank_cell }

      context 'for unexisted bank cell' do
        let(:service) { described_class.new(id: 999, amount: 1) }

        it 'returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for existed bank cell' do
        context 'for invalid data' do
          let(:service) { described_class.new(bank_cell.attributes.merge(bank: bank, amount: 0)) }

          it 'does not update bank cell' do
            service.persist?
            bank_cell.reload

            expect(bank_cell.amount).to_not eq 0
          end
        end

        context 'for valid data' do
          let(:service) { described_class.new(bank_cell.attributes.merge(bank: bank, amount: 10)) }

          it 'does not update bank cell' do
            service.persist?
            bank_cell.reload

            expect(bank_cell.amount).to eq 10
          end
        end
      end
    end
  end
end
