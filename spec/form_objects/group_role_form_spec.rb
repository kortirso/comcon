RSpec.describe GroupRoleForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { described_class.new(groupable_id: '', groupable_type: 'Event', value: {}) }

      it 'does not create new group role' do
        expect { service.persist? }.to_not change(GroupRole, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:event) { create :event }

      context 'for existed groupable' do
        let(:service) { described_class.new(groupable_id: 'unexisted', groupable_type: 'Event', value: {}) }

        it 'does not create new group role' do
          expect { service.persist? }.to_not change(GroupRole, :count)
        end

        it 'and returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for unexisted groupable' do
        let(:service) { described_class.new(groupable_id: event.id, groupable_type: 'Event', value: { tanks: { amount: 0 } }) }

        it 'creates new group role' do
          expect { service.persist? }.to change { GroupRole.count }.by(1)
        end

        it 'and returns true' do
          expect(service.persist?).to eq true
        end
      end
    end

    context 'for updating' do
      let!(:group_role) { create :group_role }

      context 'for unexisted group role' do
        let(:service) { described_class.new(id: 'unexisted') }

        it 'returns false' do
          expect(service.persist?).to eq false
        end
      end

      context 'for existed group role' do
        context 'for invalid data' do
          let(:service) { described_class.new(group_role.attributes.merge(value: '', left_value: '')) }

          it 'does not update group role' do
            service.persist?
            group_role.reload

            expect(group_role.value).to_not eq ''
          end
        end

        context 'for valid data' do
          let(:service) { described_class.new(group_role.attributes.merge(value: { tanks: { amount: 0 } }, left_value: { tanks: { amount: 0 } })) }

          it 'does not update dungeon' do
            service.persist?
            group_role.reload

            expect(group_role.value).to eq('tanks' => { 'amount' => 0 })
          end
        end
      end
    end
  end
end
