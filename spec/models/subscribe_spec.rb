RSpec.describe Subscribe, type: :model do
  it { should belong_to :character }
  it { should belong_to :subscribeable }

  it 'factory should be valid' do
    subscribe = build :subscribe

    expect(subscribe).to be_valid
  end
end
