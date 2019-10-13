RSpec.describe Event, type: :model do
  it { should belong_to(:owner).class_name('Character') }
  it { should belong_to(:dungeon).optional }

  it 'factory should be valid' do
    event = build :event

    expect(event).to be_valid
  end
end
