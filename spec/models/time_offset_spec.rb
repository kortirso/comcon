RSpec.describe TimeOffset, type: :model do
  it { should belong_to :timeable }

  it 'factory should be valid' do
    time_offset = build :time_offset

    expect(time_offset).to be_valid
  end
end
