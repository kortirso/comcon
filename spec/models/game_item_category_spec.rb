# frozen_string_literal: true

RSpec.describe GameItemCategory, type: :model do
  it { is_expected.to have_many(:game_items).dependent(:destroy) }
  it { is_expected.to have_many(:game_item_subcategories).through(:game_items) }

  it 'factory is_expected.to be valid' do
    game_item_category = build :game_item_category

    expect(game_item_category).to be_valid
  end

  context 'self.dependencies' do
    let!(:game_item_category) { create :game_item_category }
    let!(:game_item_subcategory) { create :game_item_subcategory }
    let!(:game_item) { create :game_item, game_item_category: game_item_category, game_item_subcategory: game_item_subcategory }

    it 'returns hash with dependencies' do
      result = described_class.dependencies

      expect(result.is_a?(Hash)).to eq true
    end
  end

  describe '.to_hash' do
    let!(:game_item_category) { create :game_item_category }

    it 'returns hashed game_item_category' do
      result = game_item_category.to_hash

      expect(result.keys).to eq [game_item_category.id.to_s]
      expect(result.values[0].keys).to eq %w[name subcategories]
    end
  end
end
