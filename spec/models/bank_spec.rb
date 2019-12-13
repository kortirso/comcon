RSpec.describe Bank, type: :model do
  it { should belong_to :guild }
  it { should have_many(:bank_cells).dependent(:destroy) }

  it 'factory should be valid' do
    bank = build :bank

    expect(bank).to be_valid
  end
end