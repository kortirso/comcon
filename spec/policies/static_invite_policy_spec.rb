describe StaticInvitePolicy do
  let!(:user) { create :user }

  describe '#index?' do
    context 'if static invite goes from static' do
      let(:policy) { described_class.new('true', user: user, static: static, character: character) }

      context 'if user has role in static' do
        let!(:character) { create :character, user: user }
        let!(:static) { create :static, staticable: character }

        it 'returns true' do
          expect(policy_access).to eq true
        end
      end

      context 'if user does not have role in static' do
        let!(:character) { create :character }
        let!(:static) { create :static, staticable: character }

        it 'returns false' do
          expect(policy_access).to eq false
        end
      end
    end

    context 'if static invite goes from character' do
      let(:policy) { described_class.new('false', user: user, static: static, character: character) }
      let!(:static) { create :static, :guild }

      context 'if character is users' do
        let!(:character) { create :character, user: user }

        it 'returns true' do
          expect(policy_access).to eq true
        end
      end

      context 'if character is not users' do
        let!(:character) { create :character }

        it 'returns false' do
          expect(policy_access).to eq false
        end
      end
    end

    def policy_access
      policy.index?
    end
  end

  describe '#approve?' do
    context 'if static invite goes from character' do
      let(:policy) { described_class.new('false', user: user, static: static, character: character) }

      context 'if user has role in static' do
        let!(:character) { create :character, user: user }
        let!(:static) { create :static, staticable: character }

        it 'returns true' do
          expect(policy_access).to eq true
        end
      end

      context 'if user does not have role in static' do
        let!(:character) { create :character }
        let!(:static) { create :static, staticable: character }

        it 'returns false' do
          expect(policy_access).to eq false
        end
      end
    end

    context 'if static invite goes from static' do
      let(:policy) { described_class.new('true', user: user, static: static, character: character) }
      let!(:static) { create :static, :guild }

      context 'if character is users' do
        let!(:character) { create :character, user: user }

        it 'returns true' do
          expect(policy_access).to eq true
        end
      end

      context 'if character is not users' do
        let!(:character) { create :character }

        it 'returns false' do
          expect(policy_access).to eq false
        end
      end
    end

    def policy_access
      policy.approve?
    end
  end
end
