RSpec.describe CalcItemLevelForCharacters, type: :service do
  describe '.call' do
    let!(:character) { create :character, item_level: 0, item_level_calculated: false }
    let!(:service) { CalcItemLevelForCharacters.new }

    context 'for character with uploaded game items' do
      let!(:game_item) { create :game_item, level: 17 }
      let!(:equipment) { create :equipment, character: character, game_item: game_item }

      context 'updated character item level' do
        let(:request) { service.call }

        it 'updated character' do
          request
          character.reload

          expect(character.item_level_calculated).to eq true
          expect(character.item_level).to eq 1
        end
      end
    end

    context 'for character with uploaded game items' do
      let!(:equipment) { create :equipment, character: character, game_item: nil }

      context 'updated character item level' do
        let(:request) { service.call }

        it 'does not update character' do
          request
          character.reload

          expect(character.item_level_calculated).to eq false
          expect(character.item_level).to eq 0
        end
      end
    end
  end
end
