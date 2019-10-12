RSpec.describe Race, type: :model do
  it { should belong_to :fraction }

  it 'factory should be valid' do
    race = build :race, :human

    expect(race).to be_valid
  end
end
