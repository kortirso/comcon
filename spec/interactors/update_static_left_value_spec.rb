describe UpdateStaticLeftValue do
  let!(:static) { create :static, :guild }
  let(:value) do
    {
      tanks: {
        by_class: { warrior: 2, paladin: 0, druid: 2 }
      },
      healers: {
        by_class: { paladin: 2, druid: 1, priest: 3, shaman: 0 }
      },
      dd: {
        by_class: { warrior: 2, warlock: 5, druid: 0, hunter: 0, rogue: 0, priest: 0, shaman: 0, mage: 5, paladin: 2 }
      }
    }
  end
  let!(:group_role) { create :group_role, groupable: static, value: value }

  describe '.call' do
    let(:interactor) { described_class.call(static: static) }

    context 'without subscribes' do
      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and values for group role are the same' do
        interactor
        group_role.reload

        expect(group_role.value['dd']['by_class']['paladin']).to eq 2
        expect(group_role.left_value['dd']['by_class']['paladin']).to eq 2
      end
    end

    context 'with subscribes' do
      let!(:character) { create :character }
      let!(:subscribe) { create :subscribe, character: character, subscribeable: static, status: 3 }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and values for group role are the same' do
        interactor
        group_role.reload

        expect(group_role.value['dd']['by_class']['paladin']).to eq 2
        expect(group_role.left_value['dd']['by_class']['paladin']).to eq 1
      end
    end
  end

  describe '.modify' do
    it 'for Tank return tanks' do
      expect(UpdateStaticLeftValue.new.send(:modify, 'Tank')).to eq 'tanks'
    end

    it 'for Healer return tanks' do
      expect(UpdateStaticLeftValue.new.send(:modify, 'Healer')).to eq 'healers'
    end

    it 'for Dd return tanks' do
      expect(UpdateStaticLeftValue.new.send(:modify, 'Dd')).to eq 'dd'
    end
  end
end
