# frozen_string_literal: true

RSpec.describe GuildShowSerializer do
  let!(:guild) { create :guild }
  let(:serializer) { described_class.new(guild).to_json }

  %w[id name description slug].each do |attr|
    it "serializer contains guild #{attr}" do
      expect(serializer).to have_json_path(attr)
    end
  end
end
