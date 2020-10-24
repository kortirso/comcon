# frozen_string_literal: true

RSpec.describe BankRequest, type: :model do
  it { is_expected.to belong_to :bank }
  it { is_expected.to belong_to :game_item }
  it { is_expected.to belong_to(:character).optional }

  it 'factory is_expected.to be valid' do
    bank_request = build :bank_request

    expect(bank_request).to be_valid
  end

  describe '.decline' do
    let!(:bank_request) { create :bank_request }

    it 'updates status to declined' do
      bank_request.decline
      bank_request.reload

      expect(bank_request.status).to eq 'declined'
    end
  end
end
