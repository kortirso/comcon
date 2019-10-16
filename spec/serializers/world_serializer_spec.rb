RSpec.describe WorldSerializer do
  let!(:world) { create :world }
  let(:serializer) { described_class.new(world).to_json }

  %w[id name].each do |attr|
    it "serializer contains world #{attr}" do
      expect(serializer).to have_json_path(attr)
    end
  end
end
