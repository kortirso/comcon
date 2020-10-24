# frozen_string_literal: true

RSpec.describe StaticInvite, type: :model do
  it { is_expected.to belong_to :static }
  it { is_expected.to belong_to :character }

  it 'factory is_expected.to be valid' do
    static_invite = build :static_invite

    expect(static_invite).to be_valid
  end
end
