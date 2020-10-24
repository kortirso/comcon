# frozen_string_literal: true

RSpec.describe FractionForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { described_class.new(name: { 'en' => '', 'ru' => '' }) }

      it 'does not create new fraction' do
        expect { service.persist? }.not_to change(Fraction, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:fraction) { create :fraction, :horde }

      context 'for existed fraction' do
        let(:service) { described_class.new(name: { 'en' => fraction.name['en'], 'ru' => fraction.name['ru'] }) }

        it 'does not create new fraction' do
          expect { service.persist? }.not_to change(Fraction, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for unexisted fraction' do
        let(:service) { described_class.new(name: { 'en' => 'Alliance', 'ru' => 'Альянс' }) }

        it 'creates new fraction' do
          expect { service.persist? }.to change(Fraction, :count).by(1)
        end

        it 'and returns true' do
          expect(service.persist?).to eq true
        end
      end
    end
  end
end
