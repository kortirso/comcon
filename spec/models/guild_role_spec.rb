RSpec.describe GuildRole, type: :model do
  it { should belong_to :guild }
  it { should belong_to :character }

  it 'factory should be valid' do
    guild_role = build :guild_role

    expect(guild_role).to be_valid
  end
end
