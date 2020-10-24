# frozen_string_literal: true

describe CreateDelivery do
  let!(:notification) { create :notification }
  let!(:guild) { create :guild }

  describe '.call' do
    context 'for existed delivery' do
      let!(:delivery) { create :delivery, deliveriable: guild, notification: notification }
      let(:interactor) { described_class.call(delivery_params: { deliveriable_id: guild.id, deliveriable_type: 'Guild', notification: notification }) }

      it 'fails' do
        expect(interactor).to be_a_failure
      end

      it 'and does not create delivery' do
        expect { interactor }.not_to change(Delivery, :count)
      end
    end

    context 'for unexisted delivery' do
      let(:interactor) { described_class.call(delivery_params: { deliveriable_id: guild.id, deliveriable_type: 'Guild', notification: notification }) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and creates delivery' do
        expect { interactor }.to change { guild.deliveries.count }.by(1)
      end
    end
  end

  describe '.rollback' do
    subject(:interactor) { described_class.new(delivery_params: { deliveriable_id: guild.id, deliveriable_type: 'Guild', notification: notification }) }

    it 'removes the created delivery' do
      interactor.call

      expect { interactor.rollback }.to change(Delivery, :count).by(-1)
    end
  end
end
