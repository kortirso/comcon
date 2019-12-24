RSpec.describe FastCharacterSelectSerializer do
  let!(:character) { create :character }
  let(:serializer) { described_class.new(character).serializable_hash.to_json }

  %w[name].each do |attr|
    it "serializer contains character #{attr}" do
      expect(serializer).to have_json_path("data/attributes/#{attr}")
    end
  end
end
