# frozen_string_literal: true

RSpec.describe FractionSerializer do
  let!(:fraction) { create :fraction }
  let(:serializer) { described_class.new(fraction).to_json }

  %w[id name].each do |attr|
    it "serializer contains fraction #{attr}" do
      expect(serializer).to have_json_path(attr)
    end
  end
end
