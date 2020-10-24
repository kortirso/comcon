# frozen_string_literal: true

RSpec.describe CharacterIndexSerializer do
  let!(:character) { create :character }
  let(:serializer) { described_class.new(character).to_json }

  %w[id name].each do |attr|
    it "serializer contains character #{attr}" do
      expect(serializer).to have_json_path(attr)
    end
  end
end
