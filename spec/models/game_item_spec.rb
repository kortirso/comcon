RSpec.describe GameItem, type: :model do
  it { should belong_to :game_item_quality }
  it { should belong_to(:game_item_category).optional }
  it { should belong_to(:game_item_subcategory).optional }
  it { should have_many(:bank_cells).dependent(:destroy) }

  it 'factory should be valid' do
    game_item = build :game_item

    expect(game_item).to be_valid
  end
end
