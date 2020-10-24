# frozen_string_literal: true

RSpec.describe Race, type: :model do
  it { is_expected.to belong_to :fraction }
  it { is_expected.to have_many(:characters).dependent(:destroy) }
  it { is_expected.to have_many(:combinations).dependent(:destroy) }

  it 'factory is_expected.to be valid' do
    race = build :race, :human

    expect(race).to be_valid
  end

  context 'self.dependencies' do
    let!(:race) { create :race, :human }
    let!(:character_class) { create :character_class, :warrior }
    let!(:role) { create :role, :tank }
    let!(:combination1) { create :combination, character_class: character_class, combinateable: race }
    let!(:combination2) { create :combination, character_class: character_class, combinateable: role }

    it 'returns hash with dependencies' do
      result = described_class.dependencies

      expect(result.is_a?(Hash)).to eq true
    end
  end

  describe '.to_hash' do
    let!(:race) { create :race, :human }

    it 'returns hashed race' do
      result = race.to_hash

      expect(result.keys).to eq [race.id.to_s]
      expect(result.values[0].keys).to eq %w[name fraction_id character_classes]
    end
  end
end
