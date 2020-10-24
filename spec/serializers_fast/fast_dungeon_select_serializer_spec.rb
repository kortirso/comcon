# frozen_string_literal: true

RSpec.describe FastDungeonSelectSerializer do
  let!(:dungeon) { create :dungeon }
  let(:serializer) { described_class.new(dungeon).serializable_hash.to_json }

  %w[name].each do |attr|
    it "serializer contains dungeon #{attr}" do
      expect(serializer).to have_json_path("data/attributes/#{attr}")
    end
  end
end
