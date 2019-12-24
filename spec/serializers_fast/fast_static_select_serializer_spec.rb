RSpec.describe FastStaticSelectSerializer do
  let!(:static) { create :static, :guild }
  let(:serializer) { described_class.new(static).serializable_hash.to_json }

  %w[name].each do |attr|
    it "serializer contains static #{attr}" do
      expect(serializer).to have_json_path("data/attributes/#{attr}")
    end
  end
end
