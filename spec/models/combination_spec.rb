RSpec.describe Combination, type: :model do
  it { should belong_to :character_class }
  it { should belong_to :combinateable }

  it 'factory should be valid' do
    combination = build :combination

    expect(combination).to be_valid
  end
end
