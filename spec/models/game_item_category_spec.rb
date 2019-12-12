RSpec.describe GameItemCategory, type: :model do
  it { should have_many(:game_items).dependent(:destroy) }

  it 'factory should be valid' do
    game_item_category = build :game_item_category

    expect(game_item_category).to be_valid
  end
end
