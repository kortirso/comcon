RSpec.describe GroupRoleForm, type: :service do
  let(:alliance_group_roles) do
    {
      'tanks' => {
        'by_class' => { 'warrior' => 0, 'paladin' => 0, 'druid' => 0 }
      },
      'healers' => {
        'by_class' => { 'paladin' => 0, 'druid' => 0, 'priest' => 0, 'shaman' => 3 }
      },
      'dd' => {
        'by_class' => { 'warrior' => 0, 'warlock' => 0, 'druid' => 0, 'hunter' => 0, 'rogue' => 0, 'priest' => 0, 'shaman' => 0, 'mage' => 0, 'paladin' => 0 }
      }
    }
  end
  let(:horde_group_roles) do
    {
      'tanks' => {
        'by_class' => { 'warrior' => 0, 'paladin' => 2, 'druid' => 0 }
      },
      'healers' => {
        'by_class' => { 'paladin' => 0, 'druid' => 0, 'priest' => 0, 'shaman' => 0 }
      },
      'dd' => {
        'by_class' => { 'warrior' => 0, 'warlock' => 0, 'druid' => 0, 'hunter' => 0, 'rogue' => 0, 'priest' => 0, 'shaman' => 0, 'mage' => 0, 'paladin' => 2 }
      }
    }
  end

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
        let(:service) { described_class.new(groupable_id: event.id, groupable_type: 'Event', value: GroupRole.default) }

        it 'creates new group role' do
          expect { service.persist? }.to change { GroupRole.count }.by(1)
        end

        it 'and returns true' do
          expect(service.persist?).to eq true
        end
      end

      context 'for alliance' do
        let(:service) { described_class.new(groupable_id: event.id, groupable_type: 'Event', value: alliance_group_roles) }

        it 'creates new group role' do
          expect { service.persist? }.to change { GroupRole.count }.by(1)
        end

        it 'and returns true' do
          expect(service.persist?).to eq true
        end

        it 'and reset shamans' do
          service.persist?

          expect(GroupRole.last.value['healers']['by_class']['shaman']).to eq 0
        end
      end

      context 'for horde' do
        let!(:horde) { create :fraction, :horde }
        let!(:event) { create :event, fraction: horde }
        let(:service) { described_class.new(groupable_id: event.id, groupable_type: 'Event', value: alliance_group_roles) }

        it 'creates new group role' do
          expect { service.persist? }.to change { GroupRole.count }.by(1)
        end

        it 'and returns true' do
          expect(service.persist?).to eq true
        end

        it 'and reset shamans' do
          service.persist?

          expect(GroupRole.last.value['tanks']['by_class']['paladin']).to eq 0
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
          let(:service) { described_class.new(group_role.attributes.merge(value: GroupRole.default, left_value: GroupRole.default)) }

          it 'does not update dungeon' do
            service.persist?
            group_role.reload

            expect(group_role.value.is_a?(Hash)).to eq true
          end
        end
      end
    end
  end
end
