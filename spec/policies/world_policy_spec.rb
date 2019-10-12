describe WorldPolicy do
  let!(:user) { create :user }
  let!(:admin) { create :user, :admin }

  describe '#index?' do
    context 'for simple user' do
      let(:policy) { described_class.new(nil, user: user) }

      it 'returns false' do
        expect(policy_access).to eq false
      end
    end

    context 'for admin' do
      let(:policy) { described_class.new(nil, user: admin) }

      it 'returns true' do
        expect(policy_access).to eq true
      end
    end

    def policy_access
      policy.index?
    end
  end

  describe '#new?' do
    context 'for simple user' do
      let(:policy) { described_class.new(nil, user: user) }

      it 'returns false' do
        expect(policy_access).to eq false
      end
    end

    context 'for admin' do
      let(:policy) { described_class.new(nil, user: admin) }

      it 'returns true' do
        expect(policy_access).to eq true
      end
    end

    def policy_access
      policy.new?
    end
  end

  describe '#create?' do
    context 'for simple user' do
      let(:policy) { described_class.new(nil, user: user) }

      it 'returns false' do
        expect(policy_access).to eq false
      end
    end

    context 'for admin' do
      let(:policy) { described_class.new(nil, user: admin) }

      it 'returns true' do
        expect(policy_access).to eq true
      end
    end

    def policy_access
      policy.create?
    end
  end

  describe '#edit?' do
    context 'for simple user' do
      let(:policy) { described_class.new(nil, user: user) }

      it 'returns false' do
        expect(policy_access).to eq false
      end
    end

    context 'for admin' do
      let(:policy) { described_class.new(nil, user: admin) }

      it 'returns true' do
        expect(policy_access).to eq true
      end
    end

    def policy_access
      policy.edit?
    end
  end

  describe '#update?' do
    context 'for simple user' do
      let(:policy) { described_class.new(nil, user: user) }

      it 'returns false' do
        expect(policy_access).to eq false
      end
    end

    context 'for admin' do
      let(:policy) { described_class.new(nil, user: admin) }

      it 'returns true' do
        expect(policy_access).to eq true
      end
    end

    def policy_access
      policy.update?
    end
  end

  describe '#destroy?' do
    context 'for simple user' do
      let(:policy) { described_class.new(nil, user: user) }

      it 'returns false' do
        expect(policy_access).to eq false
      end
    end

    context 'for admin' do
      let(:policy) { described_class.new(nil, user: admin) }

      it 'returns true' do
        expect(policy_access).to eq true
      end
    end

    def policy_access
      policy.destroy?
    end
  end
end
