# frozen_string_literal: true

describe CreateGroupRole do
  let!(:event) { create :event }
  let(:group_roles) { GroupRole.default }

  describe '.call' do
    context 'for invalid params' do
      let(:interactor) { described_class.call(groupable: event, group_roles: { 'group_roles' => {} }) }

      it 'fails' do
        expect(interactor).to be_a_failure
      end

      it 'and does not create new group role' do
        expect { interactor }.not_to change(GroupRole, :count)
      end
    end

    context 'for valid params' do
      let(:interactor) { described_class.call(groupable: event, group_roles: { 'group_roles' => group_roles }) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and creates new group role' do
        expect { interactor }.to change(GroupRole, :count).by(1)
      end

      it 'and provides group_role' do
        expect(interactor.group_role).to eq GroupRole.last
      end
    end
  end
end
