# frozen_string_literal: true

RSpec.describe Equipment, type: :model do
  it { is_expected.to belong_to :character }
  it { is_expected.to belong_to(:game_item).optional }

  it 'factory is_expected.to be valid' do
    equipment = build :equipment

    expect(equipment).to be_valid
  end
end
