describe CreateStaticMember do
  let!(:character) { create :character }
  let!(:static) { create :static, world: character.world, fraction: character.race.fraction, staticable: character }
  let!(:group_role) { create :group_role, groupable: static }

  describe '.call' do
    context 'for existed member' do
      let!(:static_member) { create :static_member, static: static, character: character }
      let(:interactor) { CreateStaticMember.call(static: static, character: character) }

      it 'fails' do
        expect(interactor).to be_a_failure
      end

      it 'and does not create static member' do
        expect { interactor }.to_not change(static.static_members, :count)
      end
    end

    context 'for unexisted member' do
      let(:interactor) { CreateStaticMember.call(static: static, character: character) }

      it 'succeeds' do
        expect(interactor).to be_a_success
      end

      it 'and calls CreateSubscribe' do
        expect(CreateSubscribe).to receive(:call).and_call_original

        interactor
      end

      it 'and calls UpdateStaticLeftValue' do
        expect(UpdateStaticLeftValue).to receive(:call).and_call_original

        interactor
      end

      it 'and creates static member' do
        expect { interactor }.to change { static.static_members.count }.by(1)
      end
    end
  end

  describe '.rollback' do
    subject(:interactor) { CreateStaticMember.new(static: static, character: character) }

    it 'removes the created static member' do
      interactor.call

      expect { interactor.rollback }.to change { StaticMember.count }.by(-1)
    end
  end
end
