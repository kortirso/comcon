# frozen_string_literal: true

RSpec.describe WorldFractionForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { described_class.new(world: nil, fraction: nil) }

      it 'does not create new world_fraction' do
        expect { service.persist? }.not_to change(WorldFraction, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:world) { create :world }
      let!(:fraction) { create :fraction, :alliance }

      context 'for existed world_fraction' do
        let!(:world_fraction) { create :world_fraction, world: world, fraction: fraction }
        let(:service) { described_class.new(world: world, fraction: fraction) }

        it 'does not create new world_fraction' do
          expect { service.persist? }.not_to change(WorldFraction, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for unexisted world_fraction' do
        let(:service) { described_class.new(world: world, fraction: fraction) }

        it 'creates new world_fraction' do
          expect { service.persist? }.to change(WorldFraction, :count).by(1)
        end

        it 'and returns true' do
          expect(service.persist?).to eq true
        end
      end
    end
  end
end
