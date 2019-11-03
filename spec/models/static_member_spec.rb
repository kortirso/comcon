RSpec.describe StaticMember, type: :model do
  it { should belong_to :static }
  it { should belong_to :character }

  it 'factory should be valid' do
    static_member = build :static_member

    expect(static_member).to be_valid
  end
end
