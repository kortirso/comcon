# frozen_string_literal: true

RSpec.describe BankRequestForm, type: :service do
  let!(:bank) { create :bank }
  let!(:character) { create :character }
  let!(:game_item) { create :game_item }

  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { described_class.new(bank: bank, character: character, game_item: game_item, requested_amount: 5, status: 1) }

      it 'does not create new bank request' do
        expect { service.persist? }.not_to change(BankRequest, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for no character' do
      let(:service) { described_class.new(bank: bank, character: nil, game_item: game_item, requested_amount: 5, status: 1) }

      it 'does not create new bank request' do
        expect { service.persist? }.not_to change(BankRequest, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:params) { { bank: bank, character: character, game_item: game_item, requested_amount: 5, status: 0 } }

      context 'for no bank cell' do
        let(:service) { described_class.new(params) }

        it 'does not create new bank request' do
          expect { service.persist? }.not_to change(BankRequest, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for small amount of items' do
        let!(:bank_cell) { create :bank_cell, bank: bank, game_item: game_item, amount: 1 }
        let(:service) { described_class.new(params) }

        it 'does not create new bank request' do
          expect { service.persist? }.not_to change(BankRequest, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for everything valid' do
        let!(:bank_cell) { create :bank_cell, bank: bank, game_item: game_item, amount: 10 }
        let(:service) { described_class.new(params) }

        it 'creates new bank request' do
          expect { service.persist? }.to change { bank.bank_requests.count }.by(1)
        end

        it 'and returns true' do
          expect(service.persist?).to eq true
        end
      end
    end
  end
end
