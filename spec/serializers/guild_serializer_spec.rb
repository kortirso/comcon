# frozen_string_literal: true

RSpec.describe GuildSerializer do
  let!(:guild) { create :guild }
  let(:serializer) { described_class.new(guild).to_json }

  %w[id full_name name slug fraction_id world_id].each do |attr|
    it "serializer contains guild #{attr}" do
      expect(serializer).to have_json_path(attr)
    end
  end
end
