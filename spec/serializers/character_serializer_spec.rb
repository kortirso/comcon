RSpec.describe CharacterSerializer do
  let!(:character) { create :character }
  let(:serializer) { described_class.new(character).to_json }

  %w[id name level character_class race guild subscribe_for_event].each do |attr|
    it "serializer contains character #{attr}" do
      expect(serializer).to have_json_path(attr)
    end
  end
end
