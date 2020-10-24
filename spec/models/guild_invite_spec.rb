# frozen_string_literal: true

RSpec.describe GuildInvite, type: :model do
  it { is_expected.to belong_to :guild }
  it { is_expected.to belong_to :character }

  it 'factory is_expected.to be valid' do
    guild_invite = build :guild_invite

    expect(guild_invite).to be_valid
  end
end
