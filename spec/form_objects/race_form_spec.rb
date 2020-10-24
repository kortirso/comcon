# frozen_string_literal: true

RSpec.describe RaceForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { described_class.new(name: { 'en' => '', 'ru' => '' }) }

      it 'does not create new race' do
        expect { service.persist? }.not_to change(Race, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:fraction) { create :fraction, :horde }
      let!(:race) { create :race, :orc, fraction: fraction }

      context 'for existed race' do
        let(:service) { described_class.new(name: { 'en' => race.name['en'], 'ru' => race.name['ru'] }, fraction: fraction) }

        it 'does not create new race' do
          expect { service.persist? }.not_to change(Race, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for unexisted race' do
        let(:service) { described_class.new(name: { 'en' => 'Human', 'ru' => 'Человек' }, fraction: fraction) }

        it 'creates new race' do
          expect { service.persist? }.to change(Race, :count).by(1)
        end

        it 'and returns true' do
          expect(service.persist?).to eq true
        end
      end
    end
  end
end
