# frozen_string_literal: true

describe CreateDeliveryParam do
  let!(:delivery) { create :delivery }

  describe '.call' do
    context 'for existed delivery param' do
      let!(:delivery_param) { create :delivery_param, delivery: delivery }
      let(:interactor) { described_class.call(delivery_param_params: { 'params' => { 'id' => 123, 'token' => '123' } }, delivery: delivery) }

      it 'fails' do
        expect(interactor).to be_a_failure
      end

      it 'and does not create delivery' do
        expect { interactor }.not_to change(DeliveryParam, :count)
      end
    end

    context 'for unexisted delivery param' do
      let(:interactor) { described_class.call(delivery_param_params: { 'params' => { 'id' => 123, 'token' => '123' } }, delivery: delivery) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and creates delivery' do
        expect { interactor }.to change(DeliveryParam, :count).by(1)
      end
    end
  end
end
