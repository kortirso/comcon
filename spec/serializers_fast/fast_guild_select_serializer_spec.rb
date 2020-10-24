# frozen_string_literal: true

RSpec.describe FastGuildSelectSerializer do
  let!(:guild) { create :guild }
  let(:serializer) { described_class.new(guild).serializable_hash.to_json }

  %w[full_name].each do |attr|
    it "serializer contains guild #{attr}" do
      expect(serializer).to have_json_path("data/attributes/#{attr}")
    end
  end
end
