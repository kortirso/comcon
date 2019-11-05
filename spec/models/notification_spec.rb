RSpec.describe Notification, type: :model do
  it { should have_many(:deliveries).dependent(:destroy) }
  it { should have_many(:guilds).through(:deliveries) }

  it 'factory should be valid' do
    notification = build :notification

    expect(notification).to be_valid
  end
end
