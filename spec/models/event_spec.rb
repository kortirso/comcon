RSpec.describe Event, type: :model do
  it { should belong_to(:owner).class_name('Character') }

  it 'factory should be valid' do
    event = build :event

    expect(event).to be_valid
  end
end
