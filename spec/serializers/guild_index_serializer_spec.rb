RSpec.describe GuildIndexSerializer do
  let!(:guild) { create :guild }
  let(:serializer) { described_class.new(guild).to_json }

  %w[id name description slug fraction_id fraction_name world_id world_name].each do |attr|
    it "serializer contains guild #{attr}" do
      expect(serializer).to have_json_path(attr)
    end
  end
end
