RSpec.describe GuildInvite, type: :model do
  it { should belong_to :guild }
  it { should belong_to :character }

  it 'factory should be valid' do
    guild_invite = build :guild_invite

    expect(guild_invite).to be_valid
  end
end
