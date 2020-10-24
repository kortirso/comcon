# frozen_string_literal: true

RSpec.describe Guild, type: :model do
  it { is_expected.to belong_to :world }
  it { is_expected.to belong_to :fraction }
  it { is_expected.to have_many(:characters).dependent(:nullify) }
  it { is_expected.to have_many(:users).through(:characters).source(:user) }
  it { is_expected.to have_many(:events).dependent(:destroy) }
  it { is_expected.to have_many(:guild_roles).dependent(:destroy) }
  it { is_expected.to have_many(:characters_with_role).through(:guild_roles).source(:character) }
  it { is_expected.to have_many(:head_guild_roles).class_name('GuildRole') }
  it { is_expected.to have_many(:characters_with_head_role).through(:head_guild_roles).source(:character) }
  it { is_expected.to have_many(:head_users).through(:characters_with_head_role).source(:user) }
  it { is_expected.to have_many(:banker_guild_roles).class_name('GuildRole') }
  it { is_expected.to have_many(:characters_with_banker_role).through(:banker_guild_roles).source(:character) }
  it { is_expected.to have_many(:bank_users).through(:characters_with_banker_role).source(:user) }
  it { is_expected.to have_many(:leader_guild_roles).class_name('GuildRole') }
  it { is_expected.to have_many(:characters_with_leader_role).through(:leader_guild_roles).source(:character) }
  it { is_expected.to have_many(:statics).dependent(:destroy) }
  it { is_expected.to have_many(:deliveries).dependent(:destroy) }
  it { is_expected.to have_many(:notifications).through(:deliveries) }
  it { is_expected.to have_many(:guild_invites).dependent(:destroy) }
  it { is_expected.to have_many(:character_invitations).through(:guild_invites).source(:character) }
  it { is_expected.to have_many(:banks).dependent(:destroy) }
  it { is_expected.to have_many(:activities).dependent(:destroy) }
  it { is_expected.to have_one(:time_offset).dependent(:destroy) }

  it 'factory is_expected.to be valid' do
    guild = create :guild

    expect(guild).to be_valid
  end

  describe 'methods' do
    describe '.full_name' do
      let!(:guild) { create :guild }

      it 'returns full name for guild' do
        expect(guild.full_name).to eq "#{guild.name}, #{guild.world.full_name}"
      end
    end
  end
end
