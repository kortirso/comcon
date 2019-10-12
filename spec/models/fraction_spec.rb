RSpec.describe Fraction, type: :model do
  it 'factory should be valid' do
    fraction = build :fraction, :alliance

    expect(fraction).to be_valid
  end
end
