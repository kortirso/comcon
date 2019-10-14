RSpec.describe EventSerializer do
  let!(:event) { create :event }
  let(:serializer) { described_class.new(event).to_json }

  %w[id name date time slug].each do |attr|
    it "serializer contains event #{attr}" do
      expect(serializer).to have_json_path(attr)
    end
  end
end
