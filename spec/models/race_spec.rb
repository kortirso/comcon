RSpec.describe Race, type: :model do
  it { should belong_to :fraction }
  it { should have_many(:characters).dependent(:destroy) }
  it { should have_many(:combinations).dependent(:destroy) }

  it 'factory should be valid' do
    race = build :race, :human

    expect(race).to be_valid
  end
end
