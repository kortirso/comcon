RSpec.describe GameItemSubcategory, type: :model do
  it { should have_many(:game_items).dependent(:destroy) }

  it 'factory should be valid' do
    game_item_subcategory = build :game_item_subcategory

    expect(game_item_subcategory).to be_valid
  end
end
