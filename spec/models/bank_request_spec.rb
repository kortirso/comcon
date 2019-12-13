RSpec.describe BankRequest, type: :model do
  it { should belong_to :bank }
  it { should belong_to :game_item }
  it { should belong_to(:character).optional }

  it 'factory should be valid' do
    bank_request = build :bank_request

    expect(bank_request).to be_valid
  end
end
