RSpec.describe FastWorldSerializer do
  let!(:world) { create :world }
  let(:serializer) { described_class.new(world).serializable_hash.to_json }

  %w[id name zone].each do |attr|
    it "serializer contains character #{attr}" do
      puts serializer.inspect
      expect(serializer).to have_json_path("data/attributes/#{attr}")
    end
  end
end
