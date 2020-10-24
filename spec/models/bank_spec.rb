# frozen_string_literal: true

RSpec.describe Bank, type: :model do
  it { is_expected.to belong_to :guild }
  it { is_expected.to have_many(:bank_cells).dependent(:destroy) }
  it { is_expected.to have_many(:bank_requests).dependent(:destroy) }

  it 'factory is_expected.to be valid' do
    bank = build :bank

    expect(bank).to be_valid
  end
end
