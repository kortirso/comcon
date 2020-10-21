# frozen_string_literal: true

RSpec.describe Characters::ItemLevel::CalculateService, type: :service do
  subject(:service_call) { described_class.call }

  let!(:character) { create :character, item_level: 0, item_level_calculated: false }

  context 'for character with uploaded game items' do
    before do
      game_item = create :game_item, level: 17
      create :equipment, character: character, game_item: game_item
    end

    it 'updates character' do
      service_call

      expect(character.reload.item_level_calculated).to eq true
      expect(character.reload.item_level).to eq 1
    end
  end

  context 'for character with uploaded game items' do
    before { create :equipment, character: character, game_item: nil }

    it 'does not update character' do
      service_call

      expect(character.reload.item_level_calculated).to eq false
      expect(character.reload.item_level).to eq 0
    end
  end
end
