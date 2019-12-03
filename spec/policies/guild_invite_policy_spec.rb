describe GuildInvitePolicy do
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
  let!(:character4) { create :character, guild_id: nil, user: user }

  describe '#approve?' do
    context 'for admin' do
      let(:policy) { described_class.new('false', user: admin, guild: guild3, character: guild3) }

      it 'returns false' do
        expect(policy_access).to eq false
      end
    end

    context 'if user has gm character' do
      let(:policy) { described_class.new('false', user: user, guild: guild1, character: guild1) }

      it 'returns true' do
        expect(policy_access).to eq true
      end
    end

    context 'if user has character with no gm or rl role' do
      let(:policy) { described_class.new('false', user: user, guild: guild2, character: guild2) }

      it 'returns false' do
        expect(policy_access).to eq false
      end
    end

    context 'if user has character without role' do
      let(:policy) { described_class.new('false', user: user, guild: guild3, character: guild3) }

      it 'returns false' do
        expect(policy_access).to eq false
      end
    end

    context 'if user has character without guild' do
      let(:policy) { described_class.new('true', user: user, guild: character4, character: character4) }

      it 'returns true' do
        expect(policy_access).to eq true
      end
    end

    def policy_access
      policy.approve?
    end
  end
end
