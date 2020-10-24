# frozen_string_literal: true

RSpec.describe GuildRole, type: :model do
  it { is_expected.to belong_to :guild }
  it { is_expected.to belong_to :character }

  it 'factory is_expected.to be valid' do
    guild_role = build :guild_role

    expect(guild_role).to be_valid
  end
end
