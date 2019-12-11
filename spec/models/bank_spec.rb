RSpec.describe Bank, type: :model do
  it { should belong_to :guild }

  it 'factory should be valid' do
    bank = build :bank

    expect(bank).to be_valid
  end
end
