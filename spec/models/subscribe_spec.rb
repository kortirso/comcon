RSpec.describe Subscribe, type: :model do
  it { should belong_to :event }
  it { should belong_to :character }

  it 'factory should be valid' do
    subscribe = build :subscribe

    expect(subscribe).to be_valid
  end
end
