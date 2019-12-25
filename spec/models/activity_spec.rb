RSpec.describe Activity, type: :model do
  it { should belong_to :guild }

  it 'factory should be valid' do
    activity = build :activity

    expect(activity).to be_valid
  end
end
