# frozen_string_literal: true

describe DeliveryPolicy do
  let!(:user) { create :user }
  let!(:admin) { create :user, :admin }
  let!(:guild1) { create :guild }
  let!(:character1) { create :character, guild: guild1, user: user }
  let!(:guild_role1) { create :guild_role, guild: guild1, character: character1, name: 'gm' }
  let!(:guild2) { create :guild }
  let!(:character2) { create :character, guild: guild2, user: user }
  let!(:guild_role2) { create :guild_role, guild: guild2, character: character2, name: 'cl' }
  let!(:guild3) { create :guild }
  let!(:character3) { create :character, guild: guild3, user: user }
  let!(:guild_role3) { create :guild_role, guild: guild3 }

  describe '#new?' do
    context 'for admin' do
      let(:policy) { described_class.new(guild3, user: admin) }

      it 'returns false' do
        expect(policy_access).to eq false
      end
    end

    context 'if user has gm character' do
      let(:policy) { described_class.new(guild1, user: user) }

      it 'returns true' do
        expect(policy_access).to eq true
      end
    end

    context 'if user has character with no gm or rl role' do
      let(:policy) { described_class.new(guild2, user: user) }

      it 'returns false' do
        expect(policy_access).to eq false
      end
    end

    context 'if user has character without role' do
      let(:policy) { described_class.new(guild3, user: user) }

      it 'returns false' do
        expect(policy_access).to eq false
      end
    end

    context 'for user' do
      let(:policy) { described_class.new(character1, user: user) }

      it 'returns true' do
        expect(policy_access).to eq true
      end
    end

    def policy_access
      policy.new?
    end
  end

  describe '#create?' do
    context 'for admin' do
      let(:policy) { described_class.new(guild3, user: admin) }

      it 'returns false' do
        expect(policy_access).to eq false
      end
    end

    context 'if user has gm character' do
      let(:policy) { described_class.new(guild1, user: user) }

      it 'returns true' do
        expect(policy_access).to eq true
      end
    end

    context 'if user has character with no gm or rl role' do
      let(:policy) { described_class.new(guild2, user: user) }

      it 'returns false' do
        expect(policy_access).to eq false
      end
    end

    context 'if user has character without role' do
      let(:policy) { described_class.new(guild3, user: user) }

      it 'returns false' do
        expect(policy_access).to eq false
      end
    end

    def policy_access
      policy.create?
    end
  end

  describe '#destroy?' do
    context 'for admin' do
      let(:policy) { described_class.new(guild3, user: admin) }

      it 'returns false' do
        expect(policy_access).to eq false
      end
    end

    context 'if user has gm character' do
      let(:policy) { described_class.new(guild1, user: user) }

      it 'returns true' do
        expect(policy_access).to eq true
      end
    end

    context 'if user has character with no gm or rl role' do
      let(:policy) { described_class.new(guild2, user: user) }

      it 'returns false' do
        expect(policy_access).to eq false
      end
    end

    context 'if user has character without role' do
      let(:policy) { described_class.new(guild3, user: user) }

      it 'returns false' do
        expect(policy_access).to eq false
      end
    end

    def policy_access
      policy.destroy?
    end
  end
end
