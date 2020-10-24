# frozen_string_literal: true

RSpec.describe TimeOffsetForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { described_class.new(timeable_id: nil, timeable_type: 'User', value: 0) }

      it 'does not create new time offset' do
        expect { service.persist? }.not_to change(TimeOffset, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:user) { create :user }
      let(:service) { described_class.new(timeable_id: user.id, timeable_type: 'User', value: 0) }

      it 'creates new time offset' do
        expect { service.persist? }.to change(TimeOffset, :count).by(1)
      end

      it 'and returns true' do
        expect(service.persist?).to eq true
      end
    end

    context 'for updating' do
      let!(:user) { create :user }

      context 'for unexisted time offset' do
        let(:service) { described_class.new(id: 'unexisted') }

        it 'returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for existed time offset' do
        context 'for invalid data' do
          let(:service) { described_class.new(user.time_offset.attributes.merge(value: -20)) }

          it 'does not update time offset' do
            user.reload
            service.persist?
            user.reload

            expect(user.time_offset.value).not_to eq(-20)
          end

          it 'and returns false' do
            user.reload
            expect(service.persist?).to eq false
          end
        end

        context 'for valid data' do
          let(:service) { described_class.new(user.time_offset.attributes.merge(value: 12)) }

          it 'updates time offset' do
            user.reload
            service.persist?
            user.reload

            expect(user.time_offset.value).to eq 12
          end

          it 'and returns true' do
            user.reload
            expect(service.persist?).to eq true
          end
        end
      end
    end
  end
end
