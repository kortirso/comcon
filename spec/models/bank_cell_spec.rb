RSpec.describe BankCell, type: :model do
  it { should belong_to :bank }
  it { should belong_to(:game_item).optional }

  it 'factory should be valid' do
    bank_cell = build :bank_cell

    expect(bank_cell).to be_valid
  end
end
