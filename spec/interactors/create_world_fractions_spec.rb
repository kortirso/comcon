describe CreateWorldFractions do
  let!(:world) { create :world }
  let!(:fraction1) { create :fraction, :alliance }
  let!(:fraction2) { create :fraction, :horde }

  describe '.call' do
    context 'for existed world_fraction' do
      let!(:world_fraction) { create :world_fraction, world: world, fraction: fraction1 }
      let(:interactor) { described_class.call(world: world) }

      it 'fails' do
        expect(interactor).to be_a_failure
      end

      it 'and does not create world_fractions' do
        expect { interactor }.to_not change(WorldFraction, :count)
      end
    end

    context 'for valid params' do
      let(:interactor) { described_class.call(world: world) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and creates world_fractions' do
        expect { interactor }.to change { WorldFraction.count }.by(2)
      end
    end
  end
end
