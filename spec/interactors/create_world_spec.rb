# frozen_string_literal: true

describe CreateWorld do
  describe '.call' do
    context 'for invalid params' do
      let(:interactor) { described_class.call(world_params: { name: '', zone: '' }) }

      it 'fails' do
        expect(interactor).to be_a_failure
      end

      it 'and does not create world' do
        expect { interactor }.not_to change(World, :count)
      end
    end

    context 'for valid params' do
      let(:interactor) { described_class.call(world_params: { name: 'Хроми', zone: 'RU' }) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and creates world' do
        expect { interactor }.to change(World, :count).by(1)
      end
    end
  end

  describe '.rollback' do
    subject(:interactor) { described_class.new(world_params: { name: 'Хроми', zone: 'RU' }) }

    it 'removes the created world' do
      interactor.call

      expect { interactor.rollback }.to change(World, :count).by(-1)
    end
  end
end
