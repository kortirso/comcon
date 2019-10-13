RSpec.describe Fraction, type: :model do
  it { should have_many(:races).dependent(:destroy) }
  it { should have_many(:guilds).dependent(:destroy) }

  it 'factory should be valid' do
    fraction = build :fraction, :alliance

    expect(fraction).to be_valid
  end
end
