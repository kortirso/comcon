RSpec.describe TimeOffsetForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { TimeOffsetForm.new(user: nil, value: 0) }

      it 'does not create new time offset' do
        expect { service.persist? }.to_not change(TimeOffset, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:user) { create :user }
      let(:service) { TimeOffsetForm.new(user: user, value: 0) }

      it 'creates new time offset' do
        expect { service.persist? }.to change { TimeOffset.count }.by(1)
      end

      it 'and returns true' do
        expect(service.persist?).to eq true
      end
    end

    context 'for updating' do
      let!(:user) { create :user }

      context 'for unexisted time offset' do
        let(:service) { TimeOffsetForm.new(id: 'unexisted', user: user, value: 0) }

        it 'returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for existed time offset' do
        context 'for invalid data' do
          let(:service) { TimeOffsetForm.new(id: user.time_offset.id, user: user, value: -20) }

          it 'does not update time offset' do
            service.persist?
            user.time_offset.reload

            expect(user.time_offset.value).to_not eq(-20)
          end

          it 'and returns false' do
            expect(service.persist?).to eq false
          end
        end

        context 'for valid data' do
          let(:service) { TimeOffsetForm.new(id: user.time_offset.id, user: user, value: 12) }

          it 'updates time offset' do
            service.persist?
            user.time_offset.reload

            expect(user.time_offset.value).to eq 12
          end

          it 'and returns true' do
            expect(service.persist?).to eq true
          end
        end
      end
    end
  end
end
