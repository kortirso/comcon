# frozen_string_literal: true

RSpec.describe GameItemQuality, type: :model do
  it { is_expected.to have_many(:game_items).dependent(:destroy) }

  it 'factory is_expected.to be valid' do
    game_item_quality = build :game_item_quality

    expect(game_item_quality).to be_valid
  end
end
