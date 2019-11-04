describe CreateStaticMember do
  let!(:character) { create :character }
  let!(:static) { create :static, world: character.world, fraction: character.race.fraction, staticable: character }

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

      it 'and creates static member' do
        expect { interactor }.to change { static.static_members.count }.by(1)
      end
    end
  end
end
