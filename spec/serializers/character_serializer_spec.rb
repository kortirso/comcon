# frozen_string_literal: true

RSpec.describe CharacterSerializer do
  let!(:character) { create :character }
  let(:serializer) { described_class.new(character).to_json }

  %w[id name level character_class_name race_name guild_name user_id].each do |attr|
    it "serializer contains character #{attr}" do
      expect(serializer).to have_json_path(attr)
    end
  end
end
