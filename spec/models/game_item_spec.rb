# frozen_string_literal: true

RSpec.describe GameItem, type: :model do
  it { is_expected.to belong_to :game_item_quality }
  it { is_expected.to belong_to(:game_item_category).optional }
  it { is_expected.to belong_to(:game_item_subcategory).optional }
  it { is_expected.to have_many(:bank_cells).dependent(:destroy) }
  it { is_expected.to have_many(:bank_requests).dependent(:destroy) }
  it { is_expected.to have_many(:equipment).dependent(:destroy) }

  it 'factory is_expected.to be valid' do
    game_item = build :game_item

    expect(game_item).to be_valid
  end
end
