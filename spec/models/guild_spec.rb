RSpec.describe Guild, type: :model do
  it { should belong_to :world }
  it { should belong_to :fraction }
  it { should have_many(:characters).dependent(:nullify) }
  it { should have_many(:users).through(:characters).source(:user) }
  it { should have_many(:events).dependent(:destroy) }
  it { should have_many(:guild_roles).dependent(:destroy) }
  it { should have_many(:characters_with_role).through(:guild_roles).source(:character) }
  it { should have_many(:head_guild_roles).class_name('GuildRole') }
  it { should have_many(:characters_with_head_role).through(:head_guild_roles).source(:character) }
  it { should have_many(:head_users).through(:characters_with_head_role).source(:user) }
  it { should have_many(:leader_guild_roles).class_name('GuildRole') }
  it { should have_many(:characters_with_leader_role).through(:leader_guild_roles).source(:character) }
  it { should have_many(:statics).dependent(:destroy) }
  it { should have_many(:deliveries).dependent(:destroy) }
  it { should have_many(:notifications).through(:deliveries) }
  it { should have_many(:guild_invites).dependent(:destroy) }
  it { should have_many(:character_invitations).through(:guild_invites).source(:character) }

  it 'factory should be valid' do
    guild = create :guild

    expect(guild).to be_valid
  end

  describe 'methods' do
    context '.full_name' do
      let!(:guild) { create :guild }

      it 'returns full name for guild' do
        expect(guild.full_name).to eq "#{guild.name}, #{guild.world.full_name}"
      end
    end
  end
end
