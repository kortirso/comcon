describe CreateStaticMember do
  let!(:character) { create :character }
  let!(:static) { create :static, world: character.world, fraction: character.race.fraction, staticable: character }

  describe '.call' do
    let(:interactor) { CreateStaticMember.call(static: static, character: character) }

    it 'succeeds' do
      expect(interactor).to be_a_success
    end

    it 'and creates static member' do
      expect { interactor }.to change { static.static_members.count }.by(1)
    end
  end
end
