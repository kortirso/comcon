RSpec.describe GameItemQuality, type: :model do
  it { should have_many(:game_items).dependent(:destroy) }

  it 'factory should be valid' do
    game_item_quality = build :game_item_quality

    expect(game_item_quality).to be_valid
  end
end
