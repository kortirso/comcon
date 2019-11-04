RSpec.describe StaticInvite, type: :model do
  it { should belong_to :static }
  it { should belong_to :character }

  it 'factory should be valid' do
    static_invite = build :static_invite

    expect(static_invite).to be_valid
  end
end
