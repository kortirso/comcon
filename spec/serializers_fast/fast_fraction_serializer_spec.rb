RSpec.describe FastFractionSerializer do
  let!(:fraction) { create :fraction }
  let(:serializer) { described_class.new(fraction).serializable_hash.to_json }

  %w[name].each do |attr|
    it "serializer contains fraction #{attr}" do
      expect(serializer).to have_json_path("data/attributes/#{attr}")
    end
  end
end
