RSpec.describe BankForm, type: :service do
  let!(:guild) { create :guild }

  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { described_class.new(name: '') }

      it 'does not create new bank' do
        expect { service.persist? }.to_not change(Bank, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let(:service) { described_class.new(name: 'something', coins: 100, guild: guild) }

      it 'creates new bank' do
        expect { service.persist? }.to change { Bank.count }.by(1)
      end

      it 'and returns true' do
        expect(service.persist?).to eq true
      end
    end

    context 'for updating' do
      let!(:bank) { create :bank }

      context 'for unexisted bank' do
        let(:service) { described_class.new(id: 999, name: '1') }

        it 'returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for existed bank' do
        context 'for invalid data' do
          let(:service) { described_class.new(bank.attributes.merge(guild: bank.guild, name: '')) }

          it 'does not update bank' do
            service.persist?
            bank.reload

            expect(bank.name).to_not eq ''
          end
        end

        context 'for valid data' do
          let(:service) { described_class.new(bank.attributes.merge(guild: bank.guild, name: 'Хроми')) }

          it 'does not update bank' do
            service.persist?
            bank.reload

            expect(bank.name).to eq 'Хроми'
          end
        end
      end
    end
  end
end
