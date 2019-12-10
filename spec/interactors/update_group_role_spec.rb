describe UpdateGroupRole do
  let!(:static) { create :static, :guild }
  let!(:group_role) { create :group_role, groupable: static }
  let(:group_roles) do
    {
      'tanks' => {
        'by_class' => { 'warrior' => 2, 'paladin' => 0, 'druid' => 2 }
      },
      'healers' => {
        'by_class' => { 'paladin' => 0, 'druid' => 0, 'priest' => 0, 'shaman' => 0 }
      },
      'dd' => {
        'by_class' => { 'warrior' => 0, 'warlock' => 0, 'druid' => 0, 'hunter' => 0, 'rogue' => 0, 'priest' => 0, 'shaman' => 0, 'mage' => 0, 'paladin' => 0 }
      }
    }
  end

  describe '.call' do
    context 'for invalid params' do
      let(:interactor) { described_class.call(group_role: group_role, group_roles: { 'group_roles' => '' }) }

      it 'fails' do
        expect(interactor).to be_a_failure
      end

      it 'does not call UpdateStaticLeftValue' do
        expect(UpdateStaticLeftValue).to_not receive(:call).and_call_original

        interactor
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

      it 'calls UpdateStaticLeftValue' do
        expect(UpdateStaticLeftValue).to receive(:call).and_call_original

        interactor
      end

      it 'and updates group role' do
        interactor
        group_role.reload

        expect(group_role.value['tanks']['by_class']['druid']).to eq 2
      end
    end
  end
end
