describe UpdateGroupRole do
  let!(:group_role) { create :group_role }
  let(:group_roles) { { tanks: { amount: 0 } } }

  describe '.call' do
    context 'for invalid params' do
      let(:interactor) { described_class.call(group_role: group_role, group_roles: { 'group_roles' => '' }) }

      it 'fails' do
        expect(interactor).to be_a_failure
      end

      it 'and does not update group role' do
        interactor
        group_role.reload

        expect(group_role.value).to_not eq ''
      end
    end

    context 'for valid params' do
      let(:interactor) { described_class.call(group_role: group_role, group_roles: { 'group_roles' => group_roles }) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and updates group role' do
        interactor
        group_role.reload

        expect(group_role.value).to eq('tanks' => { 'amount' => 0 })
      end
    end
  end
end
