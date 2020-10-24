# frozen_string_literal: true

RSpec.describe Profession, type: :model do
  it { is_expected.to have_many(:character_professions).dependent(:destroy) }
  it { is_expected.to have_many(:characters).through(:character_professions) }
  it { is_expected.to have_many(:recipes).dependent(:destroy) }

  it 'factory is_expected.to be valid' do
    profession = build :profession

    expect(profession).to be_valid
  end
end
