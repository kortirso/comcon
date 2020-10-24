# frozen_string_literal: true

RSpec.describe GameItemSubcategory, type: :model do
  it { is_expected.to have_many(:game_items).dependent(:destroy) }

  it 'factory is_expected.to be valid' do
    game_item_subcategory = build :game_item_subcategory

    expect(game_item_subcategory).to be_valid
  end

  describe '.to_hash' do
    let!(:game_item_subcategory) { create :game_item_subcategory }

    it 'returns hashed game_item_subcategory' do
      result = game_item_subcategory.to_hash

      expect(result.keys).to eq [game_item_subcategory.id.to_s]
      expect(result.values[0].keys).to eq %w[name]
    end
  end
end
