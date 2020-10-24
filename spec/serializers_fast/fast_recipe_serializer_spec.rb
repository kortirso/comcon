# frozen_string_literal: true

RSpec.describe FastRecipeSerializer do
  let!(:recipe) { create :recipe }
  let(:serializer) { described_class.new(recipe).serializable_hash.to_json }

  %w[name links skill profession_id].each do |attr|
    it "serializer contains character #{attr}" do
      expect(serializer).to have_json_path("data/attributes/#{attr}")
    end
  end
end
