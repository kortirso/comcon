RSpec.describe GameItemForm, type: :service do
  describe '.persist?' do
    context 'for invalid data' do
      let(:service) { described_class.new(item_uid: '', name: { 'en' => '', 'ru' => '' }) }

      it 'does not create new object' do
        expect { service.persist? }.to_not change(GameItem, :count)
      end

      it 'and returns false' do
        expect(service.persist?).to eq false
      end
    end

    context 'for valid data' do
      let!(:game_item_quality) { create :game_item_quality }
      let!(:game_item_category) { create :game_item_category }
      let!(:game_item_subcategory) { create :game_item_subcategory }
      let(:service) { described_class.new(item_uid: 11_370, name: { 'en' => 'Dark Iron Ore', 'ru' => 'Руда черного железа' }, level: 50, icon_name: 'inv_ore_mithril_01', game_item_quality: game_item_quality, game_item_category: game_item_category, game_item_subcategory: game_item_subcategory) }

      it 'creates new object' do
        expect { service.persist? }.to change { GameItem.count }.by(1)
      end

      it 'and returns true' do
        expect(service.persist?).to eq true
      end
    end
  end
end
