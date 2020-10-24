# frozen_string_literal: true

RSpec.describe BankCell, type: :model do
  it { is_expected.to belong_to :bank }
  it { is_expected.to belong_to(:game_item).optional }

  it 'factory is_expected.to be valid' do
    bank_cell = build :bank_cell

    expect(bank_cell).to be_valid
  end
end
