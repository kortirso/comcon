# frozen_string_literal: true

describe CreateDublicateForGmUser do
  describe '.call' do
    context 'for not guild_request_creation delivery' do
      let!(:delivery) { create :delivery }
      let(:interactor) { described_class.call(delivery: delivery) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and does not call CreateDeliveryWithParams' do
        expect(CreateDeliveryWithParams).not_to receive(:call).and_call_original

        interactor
      end
    end

    context 'for guild_request_creation delivery' do
      let!(:guild_notification) { create :notification, event: 'guild_request_creation', status: 0 }
      let!(:delivery) { create :delivery, notification: guild_notification }
      let(:interactor) { described_class.call(delivery: delivery) }

      context 'for unexisted user notification' do
        it 'succeeds' do
          expect(interactor).to be_a_success
        end

        it 'and does not call CreateDeliveryWithParams' do
          expect(CreateDeliveryWithParams).not_to receive(:call).and_call_original

          interactor
        end
      end

      context 'for existed user notification, user has delivery' do
        let!(:user_notification) { create :notification, event: 'guild_request_creation', status: 1 }
        let!(:gm) { create :character, guild: delivery.deliveriable }
        let!(:guild_role) { create :guild_role, character: gm, guild: delivery.deliveriable, name: 'gm' }
        let!(:existed_delivery) { create :delivery, deliveriable: gm.user, notification: user_notification }

        it 'succeeds' do
          expect(interactor).to be_a_success
        end

        it 'and does not call CreateDeliveryWithParams' do
          expect(CreateDeliveryWithParams).not_to receive(:call).and_call_original

          interactor
        end
      end

      context 'for existed user notification, user does not have delivery' do
        let!(:user_notification) { create :notification, event: 'guild_request_creation', status: 1 }
        let!(:gm) { create :character, guild: delivery.deliveriable }
        let!(:guild_role) { create :guild_role, character: gm, guild: delivery.deliveriable, name: 'gm' }

        it 'succeeds' do
          expect(interactor).to be_a_success
        end

        it 'and calls CreateDeliveryWithParams' do
          expect(CreateDeliveryWithParams).to receive(:call).and_call_original

          interactor
        end
      end
    end
  end
end
