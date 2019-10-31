describe CharacterPolicy do
  let!(:user) { create :user }
  let!(:character1) { create :character, user: user }
  let!(:character2) { create :character, :orc, world: character1.world }

  describe '#update?' do
    context 'for not user character' do
      let(:policy) { described_class.new(character2, user: user) }

      it 'returns false' do
        expect(policy_access).to eq false
      end
    end

    context 'for user character' do
      let(:policy) { described_class.new(character1, user: user) }

      it 'returns true' do
        expect(policy_access).to eq true
      end
    end

    def policy_access
      policy.update?
    end
  end
end
